from django.contrib import admin
from modules.user_engine.models import *
from unfold.admin import ModelAdmin



@admin.register(UserProfile)
class UserProfileAdmin(ModelAdmin):
    list_display = ('user', 'age', 'gender', 'is_creator', 'is_advertiser', 'creation_date', 'level', 'XP')
    list_filter = ('gender', 'is_creator', 'is_advertiser', 'creation_date')
    search_fields = ('user__username', 'bio', 'gender', "user__email")
    ordering = ('-creation_date',)
    readonly_fields = ('creation_date', 'metrics_last_updated', 'XP', 'level')
    fieldsets = (
        (None, {
            'fields': ('user', 'bio', 'age', 'gender', 'profile_picture', 'profile_banner')
        }),
        ('Subscription Info', {
            'fields': ('subscribed_to_count', 'joined_lounges')
        }),
        ('User Metrics', {
            'fields': ('XP', 'level', 'metrics_last_updated')
        }),
        ('Status', {
            'fields': ('is_creator', 'is_advertiser')
        }),
        ('Associated Models', {
            'fields': ('associated_channel', 'associated_lounge')
        }),
        ('Internal', {
            'fields': ('drafts', 'unlisted', 'lounge_only', 'active_videos', 'is_banned')
        }),
        ('Device Info', {
            'fields': ('fcm_token', 'device_model', 'os_version', )
        }),
    )


    def get_readonly_fields(self, request, obj=None):
        # Make certain fields read-only after creation
        if obj:
            return self.readonly_fields + ('user',)
        return self.readonly_fields
    


@admin.register(UserGeolocations)
class UserGeolocationsAdmin(ModelAdmin):
    list_display = ('get_user', 'city', 'country', 'region', 'last_updated')
    list_filter = ('country', 'region', 'city')
    search_fields = ('user__user__username', 'city', 'country', 'region')
    ordering = ('-last_updated',)
    readonly_fields = ('last_updated',)
    fieldsets = (
        (None, {
            'fields': ('user', 'city', 'country', 'region')
        }),
        ('Timestamps', {
            'fields': ('last_updated',)
        }),
    )



    def get_user(self, obj):
        return obj.user.user.username
    
    get_user.short_description = 'User'
    get_user.admin_order_field = 'user__user__username'


    def get_readonly_fields(self, request, obj=None):
        # Make certain fields read-only after creation
        if obj:
            return self.readonly_fields + ('user',)
        return self.readonly_fields
    


@admin.register(Channel)
class ChannelAdmin(ModelAdmin):
    list_display = ('name', 'get_user', 'subscriber_count', 'videos_count', 'level', 'XP', 'metrics_last_updated')
    list_filter = ('level', 'metrics_last_updated')
    search_fields = ('name', 'owner__user__username', 'channel_description')
    ordering = ('-metrics_last_updated',)
    readonly_fields = ('id', 'metrics_last_updated', 'level', 'XP')
    fieldsets = (
        (None, {
            'fields': ('name', 'channel_description', 'owner', 'assoicated_lounge')
        }),
        ('Subscription Info', {
            'fields': ('subscriber_count', 'videos_count')
        }),
        ('Metrics', {
            'fields': ('level', 'XP', 'metrics_last_updated')
        }),
    )

    def get_user(self, obj):
        return "@"+obj.owner.user.username
    
    get_user.short_description = 'Owner'
    get_user.admin_order_field = 'owner__user__username'

    def get_readonly_fields(self, request, obj=None):
        # Make certain fields read-only after creation
        if obj:
            return self.readonly_fields + ('name', 'owner')
        return self.readonly_fields
    

    

@admin.register(ChannelSubscribers)
class ChannelSubscribersAdmin(ModelAdmin):
    list_display = ('get_user', 'get_subscribed_user', 'creation_date')
    list_filter = ('creation_date', 'channel')
    search_fields = ('channel__name', 'subscribed_by__user__username')
    ordering = ('-creation_date',)
    readonly_fields = ('creation_date',)
    fieldsets = (
        (None, {
            'fields': ('channel', 'subscribed_by')
        }),
        ('Timestamps', {
            'fields': ('creation_date',)
        }),
    )


    def get_user(self, obj):
        return obj.channel.owner.user.username
    
    get_user.short_description = 'Owner'
    get_user.admin_order_field = 'channel__owner__user__username'

    def get_subscribed_user(self, obj):
        return "@"+obj.subscribed_by.user.username
    
    get_subscribed_user.short_description = 'Subscribed By'
    get_subscribed_user.admin_order_field = 'subscribed_by__user__username'

    def get_readonly_fields(self, request, obj=None):
        # Make certain fields read-only after creation
        if obj:
            return self.readonly_fields + ('channel', 'subscribed_by')
        return self.readonly_fields
    


@admin.register(Lounge)
class LoungeAdmin(ModelAdmin):
    list_display = ('name', 'get_user', 'total_members', 'total_categories', 'lounge_level', 'lounge_xp', 'is_public', 'metrics_last_updated')
    list_filter = ('is_public', 'lounge_level', 'metrics_last_updated')
    search_fields = ('name', 'channel__name', 'lounge_description')
    ordering = ('-metrics_last_updated',)
    readonly_fields = ('id', 'metrics_last_updated', 'lounge_xp', 'lounge_level')
    fieldsets = (
        (None, {
            'fields': ('name', 'lounge_description', 'channel', 'is_public')
        }),
        ('Membership Info', {
            'fields': ('total_members', 'total_categories', 'lounge_tiers')
        }),
        ('Metrics', {
            'fields': ('lounge_level', 'lounge_xp', 'metrics_last_updated')
        }),
    )

    def get_user(self, obj):
        return "@" + obj.channel.owner.user.username
    
    get_user.short_description = 'Owner'
    get_user.admin_order_field = 'channel__owner__user__username'

    def get_readonly_fields(self, request, obj=None):
        # Make certain fields read-only after creation
        if obj:
            return self.readonly_fields + ('name',)
        return self.readonly_fields
    


@admin.register(LoungeParticipants)
class LoungeParticipantsAdmin(ModelAdmin):
    list_display = ('get_lounge', 'get_user', 'level', 'XP', 'challenges_completed')
    list_filter = ('lounge', 'level', 'challenges_completed')
    search_fields = ('lounge__name', 'member__user__username')
    ordering = ('-level', '-XP')
    readonly_fields = ()
    fieldsets = (
        (None, {
            'fields': ('lounge', 'member')
        }),
        ('Participation Info', {
            'fields': ('level', 'XP', 'challenges_completed')
        }),
    )

    def get_user(self, obj):
        return obj.member.user.username

    def get_lounge(self, obj):
        return obj.lounge.name
    
    get_user.short_description = 'Member'
    get_user.admin_order_field = 'member__user__username'

    get_lounge.short_description = 'Lounge'
    get_lounge.admin_order_field = 'lounge__name'

    def get_readonly_fields(self, request, obj=None):
        # Make certain fields read-only after creation
        if obj:
            return self.readonly_fields + ('lounge', 'member')
        return self.readonly_fields
    


@admin.register(LoungeCategories)
class LoungeCategoriesAdmin(ModelAdmin):
    list_display = ('get_lounge', 'category_name', 'total_sections', 'creation_date')
    list_filter = ('lounge', 'creation_date')
    search_fields = ('lounge__name', 'category_name')
    ordering = ('-creation_date',)
    readonly_fields = ('creation_date',)
    fieldsets = (
        (None, {
            'fields': ('lounge', 'category_name', 'category_description', 'total_sections')
        }),
        ('Timestamps', {
            'fields': ('creation_date',)
        }),
    )

    def get_readonly_fields(self, request, obj=None):
        if obj:
            return self.readonly_fields + ('lounge', 'category_name')
        return self.readonly_fields
    
    def get_lounge(self, obj):
        return obj.lounge.name
    
    get_lounge.short_description = 'Lounge'
    get_lounge.admin_order_field = 'lounge__name'

@admin.register(LoungeSections)
class LoungeSectionsAdmin(ModelAdmin):
    list_display = ('get_lounge', 'related_category', 'section_name', 'minimum_level_required', 'only_owner_can_post', 'creation_date')
    list_filter = ('lounge', 'related_category', 'minimum_level_required', 'only_owner_can_post')
    search_fields = ('lounge__name', 'related_category__category_name', 'section_name')
    ordering = ('-creation_date',)
    readonly_fields = ('creation_date',)
    fieldsets = (
        (None, {
            'fields': ('lounge', 'related_category', 'section_name', 'section_description', 'minimum_level_required', 'only_owner_can_post')
        }),
        ('Timestamps', {
            'fields': ('creation_date',)
        }),
    )

    def get_readonly_fields(self, request, obj=None):
        if obj:
            return self.readonly_fields + ('lounge', 'related_category', 'section_name')
        return self.readonly_fields

    
    def get_lounge(self, obj):
        return obj.lounge.name
    
    get_lounge.short_description = 'Lounge'
    get_lounge.admin_order_field = 'lounge__name'


@admin.register(LoungeAccess)
class LoungeAccessAdmin(ModelAdmin):
    list_display = ('get_user', 'lounge', 'creator_videos_watched', 'invite_active')
    list_filter = ('lounge', 'invite_active')
    search_fields = ('user__user__username', 'lounge__name')
    ordering = ('user', 'lounge')
    readonly_fields = ()
    fieldsets = (
        (None, {
            'fields': ('user', 'lounge', 'creator_videos_watched', 'invite_active')
        }),
    )

    def get_user(self, obj):
        return "@" + obj.user.user.username
    
    def get_lounge(self, obj):
        return obj.lounge.name
    
    get_lounge.short_description = 'Lounge'
    get_lounge.admin_order_field = 'lounge__name'

    get_user.short_description = 'Users'
    get_user.admin_order_field = 'user__user__username'
    
@admin.register(UserExpLogs)
class UserExpLogsAdmin(ModelAdmin):
    list_display = ('get_user', 'day_difference', 'weekly_difference', 'monthly_difference', 'daily_rank', 'weekly_rank', 'monthly_rank', 'day_update_date', 'week_update_date', 'month_update_date')
    list_filter = ('day_update_date', 'week_update_date', 'month_update_date')
    search_fields = ('linked_user__user__username',)
    ordering = ('-day_update_date', '-week_update_date', '-month_update_date')
    readonly_fields = ('day_update_date', 'week_update_date', 'month_update_date')
    fieldsets = (
        ('Experience Differences', {
            'fields': ('day_difference', 'weekly_difference', 'monthly_difference')
        }),
        ('Ranking', {
            'fields': ('daily_rank', 'weekly_rank', 'monthly_rank')
        }),
        ('Timestamps', {
            'fields': ('day_update_date', 'week_update_date', 'month_update_date')
        }),
        ('User', {
            'fields': ('linked_user',)
        }),
    )

    def get_user(self, obj):
        return "@" + obj.linked_user.user.username
    
    def get_readonly_fields(self, request, obj=None):
        if obj:
            return self.readonly_fields + ('linked_user',)
        return self.readonly_fields
    
    get_user.short_description = 'User'
    get_user.admin_order_field = 'linked_user__user__username'


@admin.register(LimeLightStars)
class LimeLightStarsAdmin(ModelAdmin):
    list_display = ('get_user', 'creation_date')
    search_fields = ('linked_user__user__username',)
    list_filter = ('creation_date',)

    def get_user(self, obj):
        return "@" + obj.linked_user.user.username
    
    def get_readonly_fields(self, request, obj=None):
        if obj:
            return self.readonly_fields + ('linked_user',)
        return self.readonly_fields
    
    get_user.short_description = 'User'
    get_user.admin_order_field = 'linked_user__user__username'


@admin.register(ReportedUser)
class ReportedUserAdmin(ModelAdmin):
    list_display = ('get_user', 'get_reported_by_user', 'reason', 'added_at')
    search_fields = ('user__user__username',)
    list_filter = ('added_at',)

    def get_user(self, obj):
        return "@" + obj.user.user.username
    
    get_user.short_description = 'Username'
    get_user.admin_order_field = 'user__user__username'

    def get_reported_by_user(self, obj):
        return "@" + obj.reported_by.user.username
    
    get_reported_by_user.short_description = 'Reported by'
    get_reported_by_user.admin_order_field = 'reported_by__user__username'





@admin.register(UserAccountRemovalRequest)
class UserAccountRemovalRequestAdmin(ModelAdmin):
    list_display = ('get_user', 'reason', 'added_at')
    search_fields = ('user__user__username',)
    list_filter = ('added_at',)

    def get_user(self, obj):
        return "@" + obj.user.user.username
    
    get_user.short_description = 'Username'
    get_user.admin_order_field = 'user__user__username'




@admin.register(BlockedProfiles)
class BlockedUsersAdmin(ModelAdmin):
    list_display = ('get_user', 'get_blocked_by_user')
    search_fields = ('user__user__username',)
    list_filter = ('added_at',)

    def get_user(self, obj):
        return "@" + obj.user.user.username
    
    def get_blocked_by_user(self, obj):
        return "@" + obj.blocked_by.user.username

    
    get_user.short_description = 'Blocked User'
    get_user.admin_order_field = 'user__user__username'

    get_blocked_by_user.short_description = 'Blocked by'
    get_blocked_by_user.admin_order_field = 'blocked_by__user__username'
