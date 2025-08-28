"use client";

import React, { Suspense } from "react";
import { Canvas } from "@react-three/fiber";
import { OrbitControls } from "@react-three/drei";
import Blackhole from "../components/Blackhole";

export default function Home() {
  return (
    <Canvas
      dpr={1.5}
      camera={{
        position: [0, 0.75, -10.1],
        fov: 75,
        near: 0.1,
        far: 1000,
      }}
      style={{ width: "100vw", height: "100vh" }}
    >
      <Suspense fallback={null}>
        <Blackhole />
        <OrbitControls
          minDistance={5}
          maxDistance={12}
          enablePan={true}
          enableZoom={true}
          enableRotate={true}
        />
      </Suspense>
    </Canvas>
  );
}
