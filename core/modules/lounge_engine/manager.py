import datetime
import logging

from django.core.exceptions import ObjectDoesNotExist
from django.core.paginator import Paginator
from django.db import IntegrityError
from django.db.models import Avg, F, OuterRef, Subquery

from modules.analytics_engine.models import LogType, LoungeMetricLog, LoungePostMetricLog
from modules.lounge_engine.models import LoungePost, LoungeLike, LoungeDislike, LoungePostImpressions, ReportedPost
from modules.user_engine.manager import UserEngine
from modules.user_engine.models import (
    Lounge,
    LoungeAccess,
    LoungeCategories,
    LoungeParticipants,
    LoungeSections,
    UserProfile,
)
from modules.video_engine.models import VideoPost, VideoViews


class LoungeManager:
    """Business logic for lounges: categories, sections, posts, reactions, invites and rankings."""

    def __meta__(self):
        self.VERSION = 1.0
        self.MINIMUM_CRITERIA_VIDEO_WATCHED = 4
        self.AVERAGE_WATCH_PERCENTAGE = 0.8
        self.MAX_OBJECT_LIMIT = 30
        self.BUILD = "STABLE"

    def __init__(self):
        self.__meta__()

    def build_response(self, message):
        """Wrap a message in the standard response dictionary with status 200."""
        return {"status": 200, "message": message}

    def authenticate_and_get_user_profile(self, token):
        """Return the profile of the user behind the token, or raise if there is none."""
        try:
            logged_in_user = UserEngine().get_logged_in_user(token)
            if not logged_in_user:
                raise ObjectDoesNotExist("User not found")

            user_profile = UserEngine().get_user_profile(logged_in_user)
            if not user_profile:
                raise ObjectDoesNotExist("User profile not found")

            return user_profile

        except ObjectDoesNotExist:
            raise
        except Exception as e:
            raise Exception(f"Error occurred during authentication: {str(e)}")

    def handle_error(self, message, log_exception=True):
        """Log an error message and return it as a response."""
        if log_exception:
            logging.exception(message)
        return self.build_response(message)

    def _is_lounge_owner(self, user_profile, lounge):
        """Return True if the lounge is the profile's own lounge."""
        return user_profile.associated_lounge_id == lounge.id

    def _join_lounge(self, user_profile, lounge):
        """Add the profile to the lounge if it is not a member yet. Returns (participant, joined)."""
        participant, joined = LoungeParticipants.objects.get_or_create(member=user_profile, lounge=lounge)
        if joined:
            lounge.total_members += 1
            lounge.save()
        return participant, joined

    def _profile_for_lounge_request(self, lounge_id, token):
        """Check the lounge id and token, then return the caller's profile."""
        if lounge_id is None:
            raise Exception("Invalid Lounge ID")

        if token is None:
            raise Exception("Can't get user")

        logged_in_user = UserEngine().get_logged_in_user(token)

        if logged_in_user is None:
            raise Exception("Auth Failed")

        return UserEngine().get_user_profile_with_id(logged_in_user.id)

    def modify_lounge_details(self, token, data):
        """Update the name and description of the caller's own lounge."""
        try:
            user_profile = self.authenticate_and_get_user_profile(token)
            lounge = user_profile.associated_lounge
            lounge.name = data.get("lounge_name", lounge.name)
            lounge.lounge_description = data.get("lounge_description", lounge.lounge_description)
            lounge.save()
            return self.build_response("success")

        except Exception as e:
            return self.handle_error(f"Error occurred while modifying category: {str(e)}")

    def create_category(self, token, data):
        """Create a category in the caller's lounge."""
        try:
            user_profile = self.authenticate_and_get_user_profile(token)
            lounge_obj = self.get_lounge_obj(user_profile)

            category = LoungeCategories(
                category_name=data.get("category_name"),
                category_description=data.get("category_description"),
                lounge=lounge_obj,
            )
            category.save()

            lounge_obj.total_categories += 1
            lounge_obj.save()
            return self.build_response("success")

        except Exception as e:
            return self.handle_error(f"Error occurred while creating category: {str(e)}")

    def modify_category(self, token, data):
        """Rename or re-describe a category of the caller's lounge."""
        try:
            user_profile = self.authenticate_and_get_user_profile(token)
            category = self.get_lounge_category_obj(data["category_id"])
            if category is not None and not self._is_lounge_owner(user_profile, category.lounge):
                return self.build_response("not authorized")

            category.category_name = data.get("category_name", category.category_name)
            category.category_description = data.get("category_description", category.category_description)
            category.save()
            return self.build_response("success")

        except Exception as e:
            return self.handle_error(f"Error occurred while modifying category: {str(e)}")

    def delete_category(self, token, data):
        """Delete a category of the caller's lounge."""
        try:
            user_profile = self.authenticate_and_get_user_profile(token)
            category = self.get_lounge_category_obj(data["category_id"])
            if category is not None and not self._is_lounge_owner(user_profile, category.lounge):
                return self.build_response("not authorized")

            category.delete()

            lounge_obj = self.get_lounge_obj(user_profile)
            lounge_obj.total_categories -= 1
            lounge_obj.save()
            return self.build_response("success")

        except Exception as e:
            return self.handle_error(f"Error occurred while deleting category: {str(e)}")

    def create_section(self, token, data):
        """Create a section under a category of the caller's lounge."""
        try:
            logged_in_user = UserEngine().get_logged_in_user(token)
            user_profile = UserEngine().get_user_profile(logged_in_user)
            if user_profile:
                lounge_obj = self.get_lounge_obj(user_profile)
                category = self.get_lounge_category_obj(data["category_id"])
                if category is not None and not self._is_lounge_owner(user_profile, category.lounge):
                    return self.build_response("not authorized")

                section = LoungeSections()
                section.lounge = lounge_obj
                section.section_name = data.get("section_name")
                section.section_description = data.get("section_description")
                section.minimum_level_required = data.get("minimum_level_required")
                section.only_owner_can_post = data.get("only_owner_can_post")
                section.related_category = category
                section.save()

                category.total_sections += 1
                category.save()
                return self.build_response("success")

            return self.build_response("Token Invalid")
        except Exception as e:
            return self.build_response(f"Error occurred while creating section: {str(e)}")

    def modify_section(self, token, data):
        """Update the name, description and posting rules of a section of the caller's lounge."""
        try:
            logged_in_user = UserEngine().get_logged_in_user(token)
            user_profile = UserEngine().get_user_profile(logged_in_user)
            if user_profile:
                section = self.get_lounge_section_obj(data["section_id"])
                if section is not None and not self._is_lounge_owner(user_profile, section.lounge):
                    return self.build_response("not authorized")

                section.section_name = data.get("section_name", section.section_name)
                section.section_description = data.get("section_description", section.section_description)
                section.minimum_level_required = data.get("minimum_level_required", section.minimum_level_required)
                section.only_owner_can_post = data.get("only_owner_can_post", section.only_owner_can_post)
                section.save()
                return self.build_response("success")

            return self.build_response("Token Invalid")
        except Exception as e:
            return self.build_response(f"Error occurred while modifying section: {str(e)}")

    def delete_section(self, token, data):
        """Delete a section of the caller's lounge."""
        try:
            logged_in_user = UserEngine().get_logged_in_user(token)
            user_profile = UserEngine().get_user_profile(logged_in_user)
            if user_profile:
                section = self.get_lounge_section_obj(data["section_id"])
                if section is not None and not self._is_lounge_owner(user_profile, section.lounge):
                    return self.build_response("not authorized")

                category = section.related_category

                section.delete()

                category.total_sections -= 1
                category.save()
                return self.build_response("success")

            return self.build_response("Token Invalid")
        except Exception as e:
            return self.build_response(f"Error occurred while delete section: {str(e)}")

    def create_lounge_post(self, token, data):
        """Create a post or a reply in a section and send the matching notifications."""
        joined = False
        try:
            logged_in_user = UserEngine().get_logged_in_user(token)
            user_profile = UserEngine().get_user_profile(logged_in_user)
            if user_profile:
                section = self.get_lounge_section_obj(data["section_id"])
                participant = self.get_lounge_participant_obj(user_profile, section.lounge)

                if user_profile.associated_lounge.id != section.lounge.id and section.only_owner_can_post:
                    return self.build_response("Only owner of the lounge can post here.")

                if participant is None and (user_profile.associated_lounge.id != section.lounge.id):
                    # NOTE: only_owner_can_post is always False at this point, so this condition never
                    # holds and a non-member is always refused, even in a public lounge.
                    if section.lounge.is_public and section.only_owner_can_post != False:
                        participant, joined = self._join_lounge(user_profile, section.lounge)
                    else:
                        return self.build_response("You are not a member of this lounge.")
                lounge_post_obj = LoungePost()
                lounge_post_obj.associated_lounge_section = section
                lounge_post_obj.created_by = self.get_lounge_participant_obj(user_profile, section.lounge)
                lounge_post_obj.text = data.get("text", "")
                lounge_post_obj.attachment = data.get("attachment", None)

                needs_distribution = True
                if "parent_post_id" in data and data["parent_post_id"] is not None:
                    parent_obj = self.get_lounge_post_obj(data["parent_post_id"])
                    parent_obj.replies += 1
                    # NOTE: a top-level post has no root_post, so every reply copies None and
                    # root_post is never set. Queries that filter on root_post return nothing.
                    lounge_post_obj.root_post = parent_obj.root_post
                    lounge_post_obj.parent_post = parent_obj
                    lounge_post_obj.post_depth = parent_obj.post_depth + 1
                    parent_obj.save()
                    needs_distribution = False

                lounge_post_obj.save()
                from modules.notifier_engine.manager import notifierAgent

                if needs_distribution:
                    notifierAgent.distrubute_lounge_post_notifications(
                        UserProfile.objects.filter(associated_lounge__id=section.lounge.id).first(),
                        post=lounge_post_obj
                    )
                else:
                    notifierAgent.register_lounge_post_reply_notification(lounge_post_obj, parent_obj)

                if joined:
                    return self.build_response("Post created. Now you are now a member of this lounge.")

                return self.build_response("Post Created successfully.")

            return self.build_response("Token Invalid")
        except Exception as e:
            return self.build_response(f"Error occurred while creating lounge post: {str(e)}")

    def delete_lounge_post(self, token, post_id):
        """Delete a post if the caller wrote it, and lower the parent's reply count."""
        try:
            logged_in_user = UserEngine().get_logged_in_user(token)
            user_profile = UserEngine().get_user_profile(logged_in_user)
            if user_profile:
                lounge_post_obj = self.get_lounge_post_obj(post_id)
                lounge_participant_obj = self.get_lounge_participant_obj(
                    user_profile, lounge_post_obj.associated_lounge_section.lounge
                )
                if lounge_post_obj.created_by == lounge_participant_obj:
                    parent_obj = lounge_post_obj.parent_post
                    lounge_post_obj.delete()

                    if parent_obj is not None:
                        parent_obj.replies -= 1
                        parent_obj.save()
                    return self.build_response("success")
                else:
                    return self.build_response("not authorized")

            return self.build_response("Token Invalid")
        except Exception as e:
            return self.build_response(f"Error occurred while modifying section: {str(e)}")

    def get_object(self, object_id, model):
        """Fetch a model instance by id or raise ObjectDoesNotExist."""
        try:
            return model.objects.get(id=object_id)
        except model.DoesNotExist:
            raise ObjectDoesNotExist(f"{model.__name__} not found")

    def set_reaction(
        self, object_id, token, reaction_type, model, reaction_model, opposite_reaction_model, action_name
    ):
        """Toggle a like or dislike on a post. An existing opposite reaction is removed."""
        joined = False
        try:
            logged_in_user = UserEngine().get_logged_in_user(token)
            user_profile = UserEngine().get_user_profile_with_id(logged_in_user.id)

            obj = self.get_object(object_id, model)
            lounge = obj.associated_lounge_section.lounge
            lounge_participant_obj = self.get_lounge_participant_obj(user_profile, lounge)
            if lounge_participant_obj is None:
                if lounge.is_public:
                    lounge_participant_obj, joined = self._join_lounge(user_profile, lounge)
                else:
                    return self.build_response("You are not a member of this lounge.")

            opposite_reaction_type = "Like" if reaction_type == "Dislike" else "Dislike"
            counter = f"{reaction_type.lower()}s"
            opposite_counter = f"{opposite_reaction_type.lower()}s"
            update_fields = [counter]

            opposite_reaction = opposite_reaction_model.objects.filter(
                **{f"{opposite_reaction_type.lower()}d_by": lounge_participant_obj, "post": obj}
            ).first()

            reaction_obj, created = reaction_model.objects.get_or_create(
                **{f"{reaction_type.lower()}d_by": lounge_participant_obj, "post": obj}
            )

            if opposite_reaction:
                setattr(obj, opposite_counter, F(opposite_counter) - 1)
                opposite_reaction.delete()
                update_fields.append(opposite_counter)

            if created:
                setattr(obj, counter, F(counter) + 1)
            else:
                # Reacting a second time removes the reaction.
                setattr(obj, counter, F(counter) - 1)
                reaction_obj.delete()

            obj.save(update_fields=update_fields)

        except IntegrityError as e:
            return self.build_response(f"IntegrityError: {e}")

        except Exception as e:
            return self.build_response(f"Can't set {reaction_type}. Error: {e}")

        if joined:
            return self.build_response("You are a member of this lounge now.")

        return self.build_response("success")

    def set_like(self, post_id, token):
        """Toggle the caller's like on a post."""
        return self.set_reaction(post_id, token, "Like", LoungePost, LoungeLike, LoungeDislike, "liked")

    def set_dislike(self, post_id, token):
        """Toggle the caller's dislike on a post."""
        return self.set_reaction(post_id, token, "Dislike", LoungePost, LoungeDislike, LoungeLike, "disliked")

    def remove_reaction(self, object_id, token, reaction_type, model, reaction_model):
        """Remove the caller's like or dislike from a post and lower the counter."""
        try:
            if token is None:
                raise Exception("Can't get user")

            logged_in_user = UserEngine().get_logged_in_user(token)
            user_profile = UserEngine().get_user_profile_with_id(logged_in_user.id)

            obj = self.get_object(object_id, model)
            lounge_participant_obj = self.get_lounge_participant_obj(
                user_profile, obj.associated_lounge_section.lounge
            )
            try:
                reaction_obj = reaction_model.objects.get(
                    **{f"{reaction_type.lower()}d_by": lounge_participant_obj, "post": obj}
                )
            except reaction_model.DoesNotExist:
                return self.build_response("Post not found")

            counter = f"{reaction_type.lower()}s"
            setattr(obj, counter, F(counter) - 1)
            reaction_obj.delete()
            obj.save(update_fields=[counter])
            return self.build_response("success")
        except IntegrityError as e:
            return self.build_response(f"IntegrityError: {e}")
        except Exception as e:
            return self.build_response(f"Can't remove {reaction_type}. Error: {e}")

    def remove_like(self, post_id, token):
        """Remove the caller's like from a post."""
        return self.remove_reaction(post_id, token, "Like", LoungePost, LoungeLike)

    def remove_dislike(self, post_id, token):
        """Remove the caller's dislike from a post."""
        return self.remove_reaction(post_id, token, "Dislike", LoungePost, LoungeDislike)

    def check_user_satisfies_lounge_criteria(self, lounge, user):
        """Return True if the user has watched enough of the lounge owner's videos to be invited."""
        if lounge is None or user is None:
            raise Exception("Invalid Lounge or User")

        lounge_owner_video_qs = VideoPost.objects.filter(creator=lounge.channel.owner).select_related("videoviews")
        videos_watched = VideoViews.objects.filter(video__in=lounge_owner_video_qs, viewed_by=user).annotate(
            watch_percentage=Avg("view_percentage")
        )

        if videos_watched.count() >= self.MINIMUM_CRITERIA_VIDEO_WATCHED:
            average_watch_percentage = videos_watched.aggregate(avg_watch_percentage=Avg("watch_percentage"))[
                "avg_watch_percentage"
            ]
            return average_watch_percentage >= self.AVERAGE_WATCH_PERCENTAGE
        return False

    def set_lounge_access(self, lounge, user_profile):
        """Create a lounge invite for a non-member who meets the watch criteria."""
        try:
            participant_obj = self.get_lounge_participant_obj(user_profile, lounge)

            if participant_obj is None:
                condition = self.check_user_satisfies_lounge_criteria(lounge, user_profile)
                if condition:
                    _, created = LoungeAccess.objects.get_or_create(user=user_profile, lounge=lounge)
                    if created:
                        return self.build_response("User invited to join lounge.")
                    else:
                        return self.build_response("User already invited.")
                else:
                    raise Exception("User not eligibile")
            else:
                raise Exception("Already part of the lounge.")

        except Exception as e:
            return self.build_response(f"Error while setting lounge access: {str(e)}")

    def fetch_lounge_invites(self, token, page_number):
        """List the owners of the lounges that have an active invite for the caller."""
        if token is None:
            raise Exception("Can't get user")

        logged_in_user = UserEngine().get_logged_in_user(token)

        if logged_in_user is None:
            raise Exception("Auth Failed")

        user_engine_obj = UserEngine()
        user_profile = user_engine_obj.get_user_profile_with_id(logged_in_user.id)
        access_qs = LoungeAccess.objects.filter(user=user_profile, invite_active=True)
        user_qs = UserProfile.objects.filter(user__in=access_qs.values("lounge__channel__owner__user")).exclude(
            user=logged_in_user
        )
        result = user_engine_obj.user_paginator(user_qs, page_number)
        result["total_requests"] = user_qs.count()
        return result

    def accept_lounge_request(self, lounge_id, token):
        """Accept a lounge invite: add the caller as a member and close the invite."""
        try:
            user_profile = self._profile_for_lounge_request(lounge_id, token)
            # NOTE: invite_active is not checked, so an invite that was denied or already used
            # can still be accepted.
            access_obj = self.get_lounge_access_obj(lounge_id, user_profile)

            if access_obj is None:
                raise Exception("Not Eligible / Already a member to this lounge")

            participant_obj = LoungeParticipants()
            participant_obj.lounge = access_obj.lounge
            participant_obj.member = access_obj.user
            participant_obj.save()

            access_obj.lounge.total_members += 1
            access_obj.lounge.save()

            access_obj.invite_active = False

            access_obj.save()
            return self.build_response("success")
        except Exception as e:
            return self.build_response(f"Error while making lounge participant: {str(e)}")

    def deny_lounge_request(self, lounge_id, token):
        """Decline a lounge invite by marking it inactive."""
        try:
            user_profile = self._profile_for_lounge_request(lounge_id, token)
            access_obj = self.get_lounge_access_obj(lounge_id, user_profile)

            if access_obj is None:
                raise Exception("Not Eligible / Already a member to this lounge")

            access_obj.invite_active = False
            access_obj.save()
            return self.build_response("success")
        except Exception as e:
            return self.build_response(f"Error while denying lounge invite: {str(e)}")

    def leave_lounge(self, lounge_id, token):
        """Remove the caller from a lounge and lower its member count."""
        try:
            user_profile = self._profile_for_lounge_request(lounge_id, token)
            lounge = self.get_lounge_obj_with_id(lounge_id)
            participant_obj = self.get_lounge_participant_obj(user_profile, lounge)

            if participant_obj is None:
                return self.build_response("You are not a member.")

            participant_obj.delete()
            lounge.total_members -= 1
            lounge.save()

            return self.build_response("Left Lounge.")
        except Exception as e:
            return self.build_response(f"Error while leaving lounge: {str(e)}")

    def get_lounge_post_obj(self, post_id):
        """Return the post with this id, or None."""
        return LoungePost.objects.filter(id=post_id).first()

    def get_lounge_obj_with_id(self, id):
        """Return the lounge with this id, or None."""
        return Lounge.objects.filter(id=id).first()

    def get_lounge_obj(self, user_profile):
        """Return the lounge attached to the profile's channel, or None."""
        return Lounge.objects.filter(channel=user_profile.associated_channel).first()

    def get_lounge_category_obj(self, category_id):
        """Return the category with this id, or None."""
        return LoungeCategories.objects.filter(id=category_id).first()

    def get_lounge_section_obj(self, section_id):
        """Return the section with this id, or None."""
        return LoungeSections.objects.filter(id=section_id).first()

    # NOTE: the post listing and search methods below do not check lounge visibility or
    # membership. Anyone who knows a section or post id can read posts of a private lounge.
    def fetch_section_posts(self, section_id, page_number, token=None):
        """Return a page of the top-level posts of a section, newest first."""
        lounge_section_obj = self.get_lounge_section_obj(section_id)
        post_qs = LoungePost.objects.filter(
            associated_lounge_section=lounge_section_obj, parent_post_id=None
        ).order_by("-creation_date")
        return self.paginator(post_qs, page_number, token)

    def fetch_threaded_comments(
        self,
        post_id,
        page_number,
        is_root_comment,
        token=None,
    ):
        """Return a page of replies to a post, most liked first, matched by root post or by parent post."""
        comment_obj = self.get_lounge_post_obj(post_id)

        if is_root_comment:
            comment_qs = LoungePost.objects.filter(
                root_post=comment_obj, associated_lounge_section=comment_obj.associated_lounge_section
            ).order_by("-likes")
        else:
            comment_qs = LoungePost.objects.filter(
                parent_post=comment_obj, associated_lounge_section=comment_obj.associated_lounge_section
            ).order_by("-likes")
        return self.paginator(comment_qs, page_number, token)

    def set_lounge_post_impression(self, post_id, token):
        """Record that the caller saw a post. Each user counts once per post."""
        try:
            if token is None:
                raise Exception("Invalid Token")

            if post_id is None:
                raise Exception("post_id is none")

            logged_in_user = UserEngine().get_logged_in_user(token)

            if logged_in_user is None:
                raise Exception("Auth Failed")

            user_profile = UserEngine().get_user_profile_with_id(logged_in_user.id)
            post = self.get_lounge_post_obj(post_id)

            if post is None:
                raise Exception("Invaild Post ID")

            _, created = LoungePostImpressions.objects.get_or_create(viewed_by=user_profile, post=post)
            if not created:
                raise Exception("Impression already set")

            post.impressions += 1
            post.save()
            return self.build_response("Post Impression set.")

        except Exception as e:
            return self.build_response(f"error occured while setting lounge impression:  {str(e)}")

    def get_total_comments(self, post_id, page_number, token=None):
        """Return a page of the posts under a root post up to depth 2, oldest first."""
        try:
            root_post = self.get_lounge_post_obj(post_id)
            qs = LoungePost.objects.filter(root_post=root_post, post_depth__lte=2).order_by("creation_date")
            return self.paginator(qs, page_number, token)
        except Exception as e:
            return self.build_response(f"error occured while fetching children posts:  {str(e)}")

    def get_comment_children(self, comment, depth, current_depth=1):
        """Return the direct replies of a post, then recurse into the first reply until depth is reached."""
        children = LoungePost.objects.none()

        if current_depth <= depth:
            direct_replies = LoungePost.objects.filter(parent_post=comment)

            first_node = direct_replies.first()

            if first_node is not None:
                current_depth = first_node.post_depth
                children = direct_replies | self.get_comment_children(first_node, depth, current_depth + 1)

        return children

    def fetch_child_posts(self, post_id, page_number, token=None):
        """Return a page of the replies below a post, up to 3 levels deeper, ordered by depth."""
        try:
            parent_obj = self.get_lounge_post_obj(post_id)
            max_depth = parent_obj.post_depth + 3
            child_comments = self.get_comment_children(parent_obj, max_depth, parent_obj.post_depth)
            ordered_comments = child_comments.order_by("post_depth")
            return self.paginator(ordered_comments, page_number, token)
        except Exception as e:
            return self.build_response(f"error occured while fetching children posts:  {str(e)}")

    def get_post_like_obj(self, post, participant):
        """Return the participant's like on the post, or None."""
        return LoungeLike.objects.filter(post=post, liked_by=participant).first()

    def get_post_dislike_obj(self, post, participant):
        """Return the participant's dislike on the post, or None."""
        return LoungeDislike.objects.filter(post=post, disliked_by=participant).first()

    def get_top_two_commentors(self, post):
        """Return the two most liked direct replies to a post."""
        return LoungePost.objects.filter(parent_post=post).order_by("-likes")[:2]

    def lounge_post_to_dict(self, post, token=None, ignore_fields=False):
        """Serialize a post. With a token, add the top repliers and the caller's reaction status."""
        if post is None:
            return {}
        m = {
            "id": str(post.id),
            "user_lounge": UserEngine().lounge_to_dict(post.associated_lounge_section.lounge),
            "associated_lounge_section": self.lounge_section_to_dict(post.associated_lounge_section.id),
            "created_by": self.lounge_participant_to_dict(post.created_by),
            "text": post.text,
            "attachment": post.attachment.name if post.attachment else None,
            "xp": post.xp,
            "likes": post.likes,
            "dislikes": post.dislikes,
            "replies": post.replies,
            "topic_id": post.topic_id,
            "topic_category_id": post.topic_category_id,
            "post_sentiment": post.post_sentiment,
            "impressions": post.impressions,
            "is_advertisement": post.is_advertisement,
            "post_depth": post.post_depth,
            "root_post": str(post.root_post.id) if post.root_post else None,
            "parent_post": str(post.parent_post.id) if post.parent_post else None,
            "creation_date": str(post.creation_date),
        }
        if token:
            logged_in_user = UserEngine().get_logged_in_user(token)

            top_repliers = [
                self.lounge_post_to_dict(i)["created_by"]["member"] for i in self.get_top_two_commentors(post)
            ]
            m["top_comments_by"] = list({v["user_id"]: v for v in top_repliers}.values())

            participant = self.get_lounge_participant_obj(
                user_profile=UserEngine().get_user_profile(logged_in_user),
                lounge=post.associated_lounge_section.lounge,
            )
            m["reaction_status"] = {
                "like": self.get_post_like_obj(post, participant) is not None,
                "dislike": self.get_post_dislike_obj(post, participant) is not None,
                "total_likes": LoungeLike.objects.filter(post=post).count(),
                "total_dislikes": LoungeDislike.objects.filter(post=post).count(),
            }

        return m

    def lounge_participant_to_dict(self, participant):
        """Serialize a lounge member with level and XP."""
        return {
            "lounge": UserEngine().lounge_to_dict(participant.lounge),
            "member": UserEngine().to_json(participant.member.user, participant.member),
            "level": participant.level,
            "xp": participant.XP,
            "challenges_completed": participant.challenges_completed,
        }

    def lounge_category_to_dict(self, category_id):
        """Serialize the category with this id."""
        category = self.get_lounge_category_obj(category_id)
        return {
            "id": str(category.id),
            "category_name": category.category_name,
            "category_description": category.category_description,
            "total_sections": category.total_sections,
            "creation_date": str(category.creation_date),
        }

    def lounge_section_to_dict(self, section_id):
        """Serialize the section with this id."""
        section = self.get_lounge_section_obj(section_id)
        return {
            "id": str(section.id),
            "related_category": self.lounge_category_to_dict(section.related_category.id)["category_name"],
            "section_name": section.section_name,
            "section_description": section.section_description,
            "minimum_level_required": section.minimum_level_required,
            "only_owner_can_post": section.only_owner_can_post,
            "creation_date": str(section.creation_date),
        }

    def available_categories(self, user_id):
        """List the categories of a user's lounge, oldest first."""
        try:
            lounge_categories = []
            user_profile = UserEngine().get_user_profile_with_id(user_id)
            lounge_categories_qs = LoungeCategories.objects.filter(lounge=user_profile.associated_lounge).order_by(
                "creation_date"
            )
            for category_obj in lounge_categories_qs:
                lounge_categories.append(self.lounge_category_to_dict(category_obj.id))
            return self.build_response(lounge_categories)
        except Exception as e:
            return self.build_response(f"Error occurred while fetching available categories: {str(e)}")

    def search_users(self, query, page_number, token):
        """Search profiles by username, channel name or email and add block and subscription status."""
        user_engine_obj = UserEngine()
        # NOTE: matching on email lets any caller find out which email addresses are registered.
        user_qs = (
            UserProfile.objects.filter(user__username__icontains=query)
            | UserProfile.objects.filter(associated_channel__name__icontains=query)
            | UserProfile.objects.filter(user__email__icontains=query)
        )
        logged_in_user = user_engine_obj.get_logged_in_user(token)
        pagination_result = user_engine_obj.user_paginator(user_qs, page_number)
        if "data" in pagination_result:
            for row in pagination_result["data"]:
                row["block_status"] = UserEngine().check_block(token, row["user_id"], as_bool=True)
                row["reverse_block"] = UserEngine().check_reverse_block(
                    logged_in_user.id, row["user_id"], as_bool=True
                )
                row["subscription_status"] = UserEngine().get_subscription_status(
                    row["user_channel"]["id"], logged_in_user.id, just_bool=True
                )
        return pagination_result

    def search_lounge_posts(self, query, page_number, token):
        """Return a page of posts whose text contains the query."""
        post_qs = LoungePost.objects.filter(text__icontains=query)

        return self.paginator(post_qs, page_number, token)

    def change_lounge_visibility(self, token):
        """Switch the caller's lounge between public and private."""
        try:
            if token is None:
                raise Exception("Can't get user")

            logged_in_user = UserEngine().get_logged_in_user(token)

            if logged_in_user is None:
                raise Exception("Auth Failed")

            user_profile = UserEngine().get_user_profile(logged_in_user)

            user_profile.associated_lounge.is_public = not user_profile.associated_lounge.is_public
            user_profile.associated_lounge.save()
            return self.build_response("success")

        except Exception as e:
            return self.build_response(f"Error while changing user visibility: {str(e)}")

    def _recent_day_logs(self, log_model, xp_field):
        """Return the DAY logs of the last 7 days for a metric log model, highest XP first."""
        end_date = datetime.datetime.now()
        start_date = end_date - datetime.timedelta(days=7)
        return log_model.objects.filter(log_type=LogType.DAY, log_date__range=(start_date, end_date)).order_by(
            f"-{xp_field}"
        )

    def _lounge_owners_by_recent_xp(self, lounge_qs, lounge_logs, page_number):
        """Rank lounges by their best recent daily XP and return a page of their owners."""
        top_lounge_qs = lounge_qs.annotate(
            lounge_xpl=Subquery(lounge_logs.filter(lounge=OuterRef("id")).values("lounge_xp")[:1])
        ).order_by("-lounge_xpl")

        # NOTE: the ranked lounges are only used as an IN filter here, so the XP order does not
        # carry over to the profiles that are returned.
        users_qs = UserProfile.objects.filter(associated_lounge__in=top_lounge_qs)
        return UserEngine().user_paginator(users_qs, page_number)

    def _top_posts_by_recent_xp(self, sections):
        """Return the top-level posts of the sections, ordered by their best recent daily XP."""
        post_logs = self._recent_day_logs(LoungePostMetricLog, "xp")
        return (
            LoungePost.objects.filter(associated_lounge_section__in=sections, post_depth=1)
            .annotate(lounge_xpl=Subquery(post_logs.filter(lounge_post=OuterRef("id")).values("xp")[:1]))
            .order_by("-lounge_xpl")
        )

    def get_top_lounges(self, page_number):
        """Return a page of owners of the lounges that have a daily XP log in the last 7 days."""
        lounge_logs = self._recent_day_logs(LoungeMetricLog, "lounge_xp")
        lounge_qs = Lounge.objects.filter(id__in=lounge_logs.values("lounge"))
        return self._lounge_owners_by_recent_xp(lounge_qs, lounge_logs, page_number)

    def get_top_lounge_posts(self, page_number, token):
        """Return a page of top-level posts from public lounges, ranked by recent daily XP."""
        sections = LoungeSections.objects.filter(lounge__id__in=Lounge.objects.filter(is_public=True).values("id"))
        return self.paginator(self._top_posts_by_recent_xp(sections), page_number, token)

    def get_top_user_joined_lounges(self, token, page_number):
        """Return a page of owners of the lounges the caller has joined."""
        logged_in_user = UserEngine().get_logged_in_user(token)

        if logged_in_user is None:
            raise Exception("Auth Failed")

        user_profile = UserEngine().get_user_profile_with_id(logged_in_user.id)
        user_joined_lounges = LoungeParticipants.objects.filter(member=user_profile)
        lounge_logs = self._recent_day_logs(LoungeMetricLog, "lounge_xp")
        lounge_qs = Lounge.objects.filter(id__in=user_joined_lounges.values("lounge__id"))
        return self._lounge_owners_by_recent_xp(lounge_qs, lounge_logs, page_number)

    def get_top_user_joined_lounge_posts(self, token, page_number):
        """Return a page of top-level posts from the caller's joined lounges, ranked by recent daily XP."""
        logged_in_user = UserEngine().get_logged_in_user(token)

        if logged_in_user is None:
            raise Exception("Auth Failed")

        user_profile = UserEngine().get_user_profile_with_id(logged_in_user.id)
        user_joined_lounges = LoungeParticipants.objects.filter(member=user_profile).values("lounge__id")
        relevant_sections = LoungeSections.objects.filter(lounge__in=user_joined_lounges).all()
        return self.paginator(self._top_posts_by_recent_xp(relevant_sections), page_number, token)

    def render_lounge(self, user_id, token=None):
        """Return a user's lounge with its categories and sections if the caller may see it."""
        logged_in_user = UserEngine().get_logged_in_user(token)
        logged_in_profile = UserEngine().get_user_profile_with_id(logged_in_user.id)

        lounge_sections = []
        lounge_categories = []
        user_profile = UserEngine().get_user_profile_with_id(user_id)

        access_obj = self.get_lounge_access_obj(str(user_profile.associated_lounge.id), logged_in_profile)

        if access_obj or user_profile.associated_lounge.is_public or user_profile == logged_in_profile:
            end_result = UserEngine().lounge_to_dict(user_profile.associated_lounge)
            lounge_categories_qs = LoungeCategories.objects.filter(lounge=user_profile.associated_lounge).order_by(
                "creation_date"
            )
            lounge_section_qs = LoungeSections.objects.filter(related_category__in=lounge_categories_qs).order_by(
                "creation_date"
            )

            for category_obj in lounge_categories_qs:
                lounge_categories.append(self.lounge_category_to_dict(category_obj.id))

            for section_obj in lounge_section_qs:
                lounge_sections.append(self.lounge_section_to_dict(section_obj.id))

            end_result["categories"] = lounge_categories
            end_result["sections"] = lounge_sections
            return self.build_response(end_result)

        return self.build_response("Lounge is locked.")

    def render_lounge_home(self, token):
        """Build the lounge home: up to 5 lounges and 20 posts, overall and from joined lounges."""
        top_lounges = self.get_top_lounges(1)["data"]
        top_lounge_posts = self.get_top_lounge_posts(token=token, page_number=1)["data"]
        top_lounge_user_joined = self.get_top_user_joined_lounges(token, 1)["data"]
        top_lounge_posts_user_joined = self.get_top_user_joined_lounge_posts(token, 1)["data"]

        return {
            "top_lounges": top_lounges[:5],
            "top_lounge_posts": top_lounge_posts[:20],
            "top_lounges_user_joined": top_lounge_user_joined[:5],
            "top_lounge_posts_user_joined": top_lounge_posts_user_joined[:20],
        }

    def report_post(self, token, post_id, reason):
        """File a report against a post with the caller's reason."""
        logged_in_user = UserEngine().get_logged_in_user(token)
        logged_in_profile = UserEngine().get_user_profile_with_id(logged_in_user.id)
        post_obj = self.get_lounge_post_obj(post_id)

        reported_obj = ReportedPost()
        reported_obj.post = post_obj
        reported_obj.reason = reason
        reported_obj.reported_by = logged_in_profile

        reported_obj.save()
        return self.build_response("success")

    def get_lounge_access_obj(self, lounge_id, user_profile):
        """Return the user's invite to the lounge, or None."""
        return LoungeAccess.objects.filter(lounge__id=lounge_id, user=user_profile).first()

    def get_lounge_participant_obj(self, user_profile, lounge):
        """Return the user's membership of the lounge, or None."""
        return LoungeParticipants.objects.filter(member=user_profile, lounge=lounge).first()

    def paginator(self, query_set, page_number, token):
        """Return one page of serialized posts, or an error dict if the page does not exist."""
        pagination_obj = Paginator(query_set, self.MAX_OBJECT_LIMIT)
        total_pages = pagination_obj.page_range[-1]
        if page_number > total_pages:
            return {"status": -131, "message": f"Page number does not exists. (total pages available : {total_pages})"}
        response = {
            "page_number": page_number,
            "total_pages": total_pages,
            "data": [self.lounge_post_to_dict(obj, token) for obj in pagination_obj.get_page(page_number)],
        }

        return response
