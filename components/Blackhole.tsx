import React, { useRef, useMemo } from "react";
import { useFrame, useThree } from "@react-three/fiber";
import { useCubeTexture, useTexture } from "@react-three/drei";
import * as THREE from "three";
import { uuid } from "@/lib/utils/uuid";

import vertexShader from "@/shaders/vertex.glsl";
import fragmentShader from "@/shaders/fragment.glsl";

const Blackhole: React.FC = () => {
  const meshRef = useRef<THREE.Mesh>(null);
  const { camera } = useThree();

  // Load cubemap textures
  const cubeTexture = useCubeTexture(
    ["px.png", "nx.png", "py.png", "ny.png", "pz.png", "nz.png"],
    { path: "/assets/cubemap-test/space/" },
  );

  // Load blue noise texture
  const blueNoiseTexture = useTexture("/assets/noise-textures/bn.png");

  // Configure blue noise texture
  useMemo(() => {
    if (blueNoiseTexture) {
      blueNoiseTexture.wrapS = THREE.RepeatWrapping;
      blueNoiseTexture.wrapT = THREE.RepeatWrapping;
      blueNoiseTexture.minFilter = THREE.LinearFilter;
      blueNoiseTexture.magFilter = THREE.LinearFilter;
    }
  }, [blueNoiseTexture]);

  // Create uniforms
  const uniforms = useMemo(
    () => ({
      u_time: { value: 0 },
      uMouse: { value: new THREE.Vector2() },
      uResolution: { value: new THREE.Vector2() },
      uCubemap: { value: null },
      uBlueNoiseTexture: { value: null },
      uFrame: { value: 0 },
      uCameraPosition: { value: new THREE.Vector3() },
      uCameraTarget: { value: new THREE.Vector3() },
    }),
    [],
  );

  useFrame((state, delta) => {
    const { clock } = state;

    // Get camera info
    const cameraInfo = {
      position: camera.position.clone(),
      target: (() => {
        const direction = new THREE.Vector3();
        camera.getWorldDirection(direction);
        return camera.position.clone().add(direction.multiplyScalar(10));
      })(),
      up: camera.up.clone(),
      fov: (camera as THREE.PerspectiveCamera).fov || 75,
      near: camera.near,
      far: camera.far,
    };

    if (meshRef.current) {
      const material = meshRef.current.material as THREE.ShaderMaterial;

      // Position mesh in front of camera
      const direction = new THREE.Vector3();
      camera.getWorldDirection(direction);
      meshRef.current.position.copy(camera.position);
      meshRef.current.position.add(direction.multiplyScalar(1));
      meshRef.current.lookAt(camera.position);

      // Scale mesh to cover viewport
      const distance = 1;
      const height =
        2 *
        Math.tan(
          ((camera as THREE.PerspectiveCamera).fov * (Math.PI / 180)) / 2,
        ) *
        distance;
      const width = height * (window.innerWidth / window.innerHeight);
      meshRef.current.scale.set(width, height, 1);

      // Update uniforms
      material.uniforms.u_time.value = clock.getElapsedTime();
      material.uniforms.uResolution.value = new THREE.Vector2(
        window.innerWidth * window.devicePixelRatio,
        window.innerHeight * window.devicePixelRatio,
      );
      material.uniforms.uCubemap.value = cubeTexture;
      material.uniforms.uBlueNoiseTexture.value = blueNoiseTexture;
      material.uniforms.uFrame.value += 1;
      material.uniforms.uCameraPosition.value.copy(cameraInfo.position);
      material.uniforms.uCameraTarget.value.copy(cameraInfo.target);
    }
  });

  return (
    <>
      <mesh ref={meshRef}>
        <planeGeometry args={[1, 1]} />
        <shaderMaterial
          key={uuid()}
          fragmentShader={fragmentShader}
          vertexShader={vertexShader}
          uniforms={uniforms}
          wireframe={false}
        />
      </mesh>
    </>
  );
};

export default Blackhole;
