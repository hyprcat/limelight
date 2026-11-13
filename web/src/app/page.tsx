import { Faq } from "@/components/sections/faq";
import CreatorPitch from "@/components/sections/creator-pitch";
import { Features } from "@/components/sections/features";
import Footer from "@/components/sections/footer";
import { StarCreators } from "@/components/sections/star-creators";
import { ClosingHero } from "@/components/sections/closing-hero";
import GridPattern from "@/components/ui/animated-grid-pattern";
import { MainHeader } from "@/components/sections/header";
import { Spotlight } from "@/components/sections/spotlight";
import Marquee from "react-fast-marquee";
import { cn } from "@/lib/utils";
import Image from "next/image";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between  bg-black/[0.96] p-24 max-sm:p-4 w-full">
      <MainHeader></MainHeader>
      <GridPattern
        width={40}
        height={40}
        x={-1}
        y={-1}
        className={cn(
          "[mask-image:linear-gradient(to_bottom,white,transparent,transparent)] ",
        )}
      ></GridPattern>{" "}
      <Spotlight></Spotlight>
      <h4 className="mb-2 font-normal text-base text-neutral-500 max-w-lg mx-auto">
        Partners
      </h4>
      <Marquee
        className="flex w-1/4 md:items-center md:justify-center max-w-6xl mx-auto "
        play={true}
        autoFill={true}
        pauseOnClick={false}
        pauseOnHover={true}
      >
        <Image
          src="/assets/aws_for_startups.png"
          width={170}
          height={100}
          alt="AWS logo"
          style={{
            filter: "brightness(1000%) contrast(0%)",
            margin: "16px",
          }}
        />
        <Image
          src="/assets/razorpayrize.png"
          width={250}
          height={120}
          alt="RazorPay Rize Logo"
          style={{
            filter: "brightness(1000%) contrast(0%)",
            marginLeft: "40px",
          }}
        />
        <Image
          src="/assets/DigitalOcean_logo.png"
          width={250}
          height={120}
          alt="Digital Ocean Logo"
          style={{
            filter: "brightness(1000%) contrast(0%)",
            marginLeft: "50px",
            marginRight: "10px",
          }}
        />
        <Image
          src="/assets/ibm.png"
          width={80}
          height={120}
          alt="IBM"
          style={{
            filter: "brightness(1000%) contrast(0%)",
            marginLeft: "40px",
            marginRight: "50px",
          }}
        />
      </Marquee>
      <Spacer></Spacer>
      <CreatorPitch></CreatorPitch>
      <div id="" className="px-8">
        <h4 className="text-3xl lg:text-5xl lg:leading-tight max-w-5xl mx-auto text-center tracking-tight font-medium text-black dark:text-white">
          Things that set us apart.
        </h4>

        <p className="text-sm lg:text-base  max-w-2xl  my-4 mx-auto text-neutral-500 text-center font-normal dark:text-neutral-300">
          From common features that you&apos;ll find on any social platform to
          specially curated things that no other platform offers natively - We
          have it all.
        </p>
      </div>
      <Features></Features>
      <Spacer></Spacer>
      <div
        style={{
          width: 50,
          height: 50,
          marginTop: 20,
        }}
      />
      <div className="px-8">
        <h4 className="text-3xl lg:text-5xl lg:leading-tight max-w-5xl mx-auto text-center tracking-tight font-medium text-black dark:text-white">
          ✨ LimeLight Stars
        </h4>

        <p className="text-sm lg:text-base  max-w-2xl  my-4 mx-auto text-neutral-500 text-center font-normal dark:text-neutral-300">
          Creators who have been most active on our platform and supported us
          from the start.
        </p>
      </div>
      <StarCreators></StarCreators>
      <div className="m-10"></div>
      <div className="px-8">
        <h4 className="text-3xl lg:text-5xl lg:leading-tight max-w-5xl mx-auto text-center tracking-tight font-medium text-black dark:text-white">
          General FAQ
        </h4>
      </div>
      <Spacer></Spacer>
      <Faq></Faq>
      <ClosingHero></ClosingHero>
      <Footer></Footer>
    </main>
  );
}

const Spacer = () => (
  <div
    style={{
      width: 50,
      height: 30,
      marginTop: 20,
    }}
  />
);
