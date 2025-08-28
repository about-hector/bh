# Blackhole Visualization

A WebGL-based black hole simulation with gravitational lensing, accretion disk, and realistic physics.

## Features

- Real-time gravitational lensing effects
- Volumetric accretion disk with physically-based lighting
- Blue noise temporal anti-aliasing
- Interactive camera controls
- Cubemap environment reflection

## Requirements

### Texture Assets

The following texture files need to be placed in the specified directories:

#### Cubemap Textures
Place these 6 files in `/public/assets/cubemap-test/space/`:
- `px.png` - Positive X face (right)
- `nx.png` - Negative X face (left)
- `py.png` - Positive Y face (top)
- `ny.png` - Negative Y face (bottom)
- `pz.png` - Positive Z face (front)
- `nz.png` - Negative Z face (back)

These should be space/star field images for the environment mapping.

#### Blue Noise Texture
Place this file in `/public/assets/noise-textures/`:
- `bn.png` - Blue noise texture for temporal anti-aliasing

This should be a 1024x1024 blue noise pattern.

## Getting Started

1. Install dependencies:
```bash
npm install
```

2. Add the required texture files (see Requirements above)

3. Start the development server:
```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000) in your browser

5. Click "Enter the Blackhole" to view the simulation

## Controls

- **Mouse drag**: Rotate camera around the black hole
- **Mouse wheel**: Zoom in/out
- **Right-click drag**: Pan camera

## Technical Details

The implementation includes:
- Custom GLSL vertex and fragment shaders
- Volumetric ray marching for the accretion disk
- Gravitational lensing physics simulation
- Simplex noise for disk turbulence
- Real-time cubemap reflection sampling
- Blue noise dithering for smooth temporal effects

Built with Next.js, React Three Fiber, and Three.js.