"use client";
import React from "react";
import { profilePicture } from "@/lib/api";
import { LayoutGrid } from "@/components/ui/layout-grid";

export function StarCreators() {
  return (
    <div className="h-screen w-full">
      <LayoutGrid cards={cards} />
    </div>
  );
}

const SkeletonOne = () => {
  return (
    <div>
      <p className="font-bold md:text-4xl text-xl text-white mb-5">
        @creator_one
      </p>
      <p className="font-normal text-base text-white"></p>
    </div>
  );
};

const SkeletonTwo = () => {
  return (
    <div>
      <p className="font-bold md:text-4xl text-xl text-white mb-5">
        @creator_two
      </p>
      <p className="font-normal text-base text-white"></p>
    </div>
  );
};
const SkeletonThree = () => {
  return (
    <div>
      <p className="font-bold md:text-4xl text-xl text-white mb-5">
        @creator_three
      </p>
      <p className="font-normal text-base text-white"></p>
    </div>
  );
};
const SkeletonFour = () => {
  return (
    <div>
      <p className="font-bold md:text-4xl text-xl text-white mb-5">
        @creator_four
      </p>
      <p className="font-normal text-base text-white"></p>
    </div>
  );
};

const cards = [
  {
    id: 1,
    content: <SkeletonOne />,
    className: "md:col-span-2",
    thumbnail: profilePicture("creator_one"),
  },
  {
    id: 2,
    content: <SkeletonTwo />,
    className: "col-span-1",
    thumbnail: profilePicture("creator_two"),
  },
  {
    id: 3,
    content: <SkeletonThree />,
    className: "col-span-1",
    thumbnail: profilePicture("creator_three"),
  },
  {
    id: 4,
    content: <SkeletonFour />,
    className: "md:col-span-2",
    thumbnail: profilePicture("creator_four"),
  },
];
