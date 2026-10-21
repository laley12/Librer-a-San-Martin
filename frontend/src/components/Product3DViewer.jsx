/**
 * ============================================================
 * Product3DViewer.jsx - Gráfico 3D Interactivo
 * Librería San Martín - Tarea 6
 * ============================================================
 *
 * Componente React que muestra una caja de libro/producto
 * tridimensional interactiva utilizando:
 *   - @react-three/fiber        (React renderer para Three.js)
 *   - @react-three/drei         (Utilities para Three.js)
 *   - Three.js                  (3D engine)
 *
 * Características:
 *   - Caja de libro giratoria (bookbox mesh)
 *   - Rotación controlada por el mouse (orbit control)
 *   - Zoom con scroll
 *   - Sombra y iluminación realista
 *
 * Instalación de dependencias:
 *   npm install three @react-three/fiber @react-three/drei
 */

import React, { useRef, useState } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, Float, Text } from '@react-three/drei';
import * as THREE from 'three';

// ============================================================
// Sub-componente: Caja de libro 3D
// ============================================================
function BookBox({ productId = '0001', title = 'Juguete 3D', subtitle = 'Librería San Martín' }) {
  const meshRef = useRef();
  const [hovered, setHovered] = useState(false);

  // Rotación suave continuamente
  useFrame((state) => {

      {/* Sinopsis de la cubierta (etiqueta con título) */}
      <mesh position={[0, 0.4, 0.4]}>
        <planeGeometry args={[1.8, 2.4]} />
        <meshStandardMaterial
          color="#d4a373"
          roughness={0.8}
          metalness={0}
          side={THREE.DoubleSide}
          transparent
          opacity={0.85}
        />
      </mesh>

      {/* Detalles decorativos en la cubierta */}
      <mesh position={[0.6, 0.6, 0.2]}>
        <circleGeometry args={[0.35, 32]} />
        <meshStandardMaterial color="#1e3c72" roughness={0.5} />
      </mesh>

      <mesh position={[-0.6, 0.6, 0.2]}>
        <cylinderGeometry args={[0.3, 0.3, 0.25, 32]} />
        <meshStandardMaterial color="#c9a86a" roughness={0.8} />
      </mesh>

      {/* Título del producto */}
      <Text
        position={[0, 1.9, 0]}
        text
        anchor={['center', 'middle']}
        fontSize={0.7}
        color="#1e3c72"
      >
        {title}
      </Text>

      {/* Subtítulo */}
      <Text
        position={[0, 1.7, 0]}
        text
        anchor={['center', 'middle']}
        fontSize={0.3}
        color="#64748b"

      {/* Información lateral del producto */}
      <div className="mt-4 grid grid-cols-2 gap-3 text-sm">
        <div className="bg-white p-3 rounded-lg border border-slate-200">
          <div className="text-xs text-slate-500">Código</div>
          <div className="font-semibold text-primary text-sm">{productInfo.id}</div>
        </div>
        <div className="bg-white p-3 rounded-lg border border-slate-200">
          <div className="text-xs text-slate-500">Categoría</div>
          <div className="font-semibold text-primary text-sm">{productInfo.category}</div>
        </div>
        <div className="bg-white p-3 rounded-lg border border-slate-200">
          <div className="text-xs text-slate-500">Stock</div>
          <div className="font-semibold text-green-600 text-sm">{productInfo.stock}</div>
        </div>
        <div className="bg-white p-3 rounded-lg border border-slate-200">
          <div className="text-xs text-slate-500">Precio</div>
          <div className="font-semibold text-primary text-sm">{productInfo.price}</div>
        </div>
      </div>

      {/* Indicadores de interacción */}
      <div className="mt-4 flex items-center justify-center gap-4 text-xs text-slate-400">
        <span className="flex items-center gap-1">
          🖱️ Arrastrar para rotar
        </span>
        <span className="flex items-center gap-1">
          🔍 Scroll para zoom
        </span>
        <span className="flex items-center gap-1">
          ☝️ Posicionar sobre el libro para detalle
        </span>
      </div>
    </div>
  );
};

export default Product3DViewer;

      >
        {subtitle}
      </Text>

      {/* Badge de categoría */}
      <Float speed={2} floatIntensity={0.5}>
        <mesh>
          <circleGeometry args={[0.5, 32]} />
          <meshStandardMaterial color="#22c55e" roughness={0.5} polygonOffset>
            <meshStandardMaterial.side={THREE.FrontSide} />
          </meshStandardMaterial>
        </mesh>
      </Float>

      <Text
        position={[0, 0.8, 0]}
        text
        anchor={['center', 'middle']}
        fontSize={0.45}
        color="#22c55e"
      >
        ✓ EN STOCK
      </Text>
    </group>
  );
}

// ============================================================
// Componente principal: Product3DViewer
// ============================================================
const Product3DViewer = ({ productId = '0001', title = 'Juguete 3D' }) => {
  const [showControls, setShowControls] = useState(true);

  // Información del producto
  const productInfo = {
    id: productId,
    title: title,
    description: 'Caja de libro tridimensional interactiva',
    category: 'Tecnologías Educativas',
    stock: '100 unidades',
    price: 'Bs 299.00',
    minThreshold: '0001, 0002, 0003',
  };

  return (
    <div
      className="product-3d-container"
      data-commentable
      onMouseEnter={() => setShowControls(true)}
      onMouseLeave={() => setShowControls(false)}
    >
      {/* Canvas 3D */}
      <Canvas
        shadows
        dpr={[1, 2]}
        gl={{ antialias: true, alpha: false }}
        camera={{
          position: [4, 3, 4],
          fov: 50,
          near: 0.1,
          far: 100,
        }}
      >
        <color attach="background" args={['#f1f5f9']} />
        <ambientLight intensity={0.4} />
        <directionalLight
          position={[10, 10, 5]}
          intensity={1.2}
          castShadow
          shadow-mapSize={[1024, 1024]}
        />
        <pointLight position={[-5, 5, -5]} intensity={0.8} color="#fbbf24" />

        <OrbitControls
          autoRotate
          autoRotateSpeed={2.0}
          enableZoom={true}
          enablePan={false}
          minDistance={2}
          maxDistance={12}
          target={[0, 0.8, 0]}
          makeDefault
        />

        <Float speed={1.5} floatIntensity={0.3}>
          <BookBox
            productId={productId}
            title={title}
            subtitle="Librería San Martín 2026"
          />
        </Float>

        {/* Etiqueta de información flotante */}
        <Float speed={0.8} floatIntensity={0.5}>
          <group position={[0, 4.2, 0]}>
            <boxGeometry args={[3.2, 0.6, 0.2]} />
            <meshStandardMaterial color="#1e3c72" roughness={0.5} />
          </group>
          <Text
            position={[0, 0.3, 0]}
            text
            anchor={['center', 'middle']}
            fontSize={0.35}
            color="#ffffff"
          >
            {productInfo.title}
          </Text>
        </Float>
      </Canvas>

    if (meshRef.current) {
      meshRef.current.rotation.x = Math.PI / 6 + (hovered ? 0.2 : 0);
      meshRef.current.rotation.y += 0.015;
    }
  });

  return (
    <group>
      {/* Sombra suave debajo del libro */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -1.2, 0]} castShadow>
        <planeGeometry args={[4, 4]} />
        <shadowMaterial opacity={0.3} color="rgba(0,0,0,0.2)" />
      </mesh>

      {/* Cuerpo del libro (caja rectangular) */}
      <mesh
        ref={meshRef}
        castShadow
        receiveShadow
        onPointerOver={() => setHovered(true)}
        onPointerOut={() => setHovered(false)}
      >
        <boxGeometry args={[2.2, 3.2, 0.8]} />
        <meshStandardMaterial
          color={hovered ? '#1e3c72' : '#14284a'}
          roughness={0.3}
          metalness={0.1}
          transparent
          opacity={0.9}
        />
      </mesh>
