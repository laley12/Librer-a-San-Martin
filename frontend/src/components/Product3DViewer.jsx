/**
 * ============================================================
 * Product3DViewer.jsx - GRAFICO 3D INTERACTIVO
 * LIBRERIA SAN MARTIN - TAREA 6
 * ============================================================
 */

import React, { useRef, useState } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, Float, Text } from '@react-three/drei';
import * as THREE from 'three';

// Sub-componente: Caja de libro 3D
function BookBox({ productId, title, subtitle }) {
  const meshRef = useRef();
  const [hovered, setHovered] = useState(false);

  useFrame(() => {
    if (meshRef.current) {
      meshRef.current.rotation.x = Math.PI / 6 + (hovered ? 0.2 : 0);
      meshRef.current.rotation.y += 0.015;
    }
  });

  return (
    <group>
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -1.2, 0]} receiveShadow>
        <planeGeometry args={[4, 4]} />
        <shadowMaterial opacity={0.3} />
      </mesh>
      <mesh ref={meshRef} castShadow receiveShadow onPointerOver={() => setHovered(true)} onPointerOut={() => setHovered(false)}>
        <boxGeometry args={[2.2, 3.2, 0.8]} />
        <meshStandardMaterial color={hovered ? '#1e3c72' : '#14284a'} roughness={0.3} metalness={0.1} transparent opacity={0.9} />
      </mesh>
      <mesh position={[0, 0.4, 0.4]}>
        <planeGeometry args={[1.8, 2.4]} />
        <meshStandardMaterial color="#d4a373" roughness={0.8} metalness={0} side={THREE.DoubleSide} transparent opacity={0.85} />
      </mesh>
      <mesh position={[0.6, 0.6, 0.2]}>
        <circleGeometry args={[0.35, 32]} />
        <meshStandardMaterial color="#1e3c72" roughness={0.5} />
      </mesh>
      <mesh position={[-0.6, 0.6, 0.2]}>
        <cylinderGeometry args={[0.3, 0.3, 0.25, 32]} />
        <meshStandardMaterial color="#c9a86a" roughness={0.8} />
      </mesh>
      <Text position={[0, 1.9, 0]} text={title} anchor={['center', 'middle']} fontSize={0.7} color="#1e3c72">
        <meshStandardMaterial color="#14284a" />
      </Text>
      <Text position={[0, 1.7, 0]} text={subtitle} anchor={['center', 'middle']} fontSize={0.3} color="#64748b">
        <meshStandardMaterial color="#64748b" />
      </Text>
      <Float speed={2} floatIntensity={0.5}>
        <mesh>
          <circleGeometry args={[0.5, 32]} />
          <meshStandardMaterial color="#22c55e" roughness={0.5} polygonOffset />
        </mesh>
        <Text position={[0, 0, 0.01]} text="EN STOCK" anchor={['center', 'middle']} fontSize={0.25} color="#ffffff" />
      </Float>
    </group>
  );
}

class CanvasErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }
  static getDerivedStateFromError() {
    return { hasError: true };
  }
  componentDidCatch(error) {
    console.warn("Product3DViewer Canvas Error:", error);
  }
  render() {
    if (this.state.hasError) {
      return (
        <div className="w-full h-full flex flex-col items-center justify-center bg-slate-900 rounded-xl text-white p-6 text-center">
          <div className="w-24 h-36 bg-gradient-to-r from-blue-700 to-indigo-600 rounded-lg shadow-xl mb-3 flex items-center justify-center font-bold text-xs">
            3D PRODUCT
          </div>
          <p className="text-xs text-slate-300">Modelo 3D en modo compatible</p>
        </div>
      );
    }
    return this.props.children;
  }
}

// Componente principal: Product3DViewer
const Product3DViewer = ({ productId = '0001', title = 'Juguete 3D' }) => {
  const [showControls, setShowControls] = useState(true);
  const productInfo = {
    id: productId,
    title: title,
    description: 'Caja de libro tridimensional interactiva',
    category: 'Tecnologias Educativas',
    stock: '100 unidades',
    price: 'Bs 299.00',
  };

  return (
    <div className="product-3d-container w-full max-w-4xl mx-auto" data-commentable>
      <div className="h-[500px] w-full mb-6 relative">
        <CanvasErrorBoundary>
          <Canvas camera={{ position: [0, 1, 5], fov: 50 }} gl={{ antialias: true, alpha: false, failIfMajorPerformanceCaveat: false }} fallback={<div className="w-full h-full flex items-center justify-center bg-slate-900 text-white text-xs">Cargando 3D...</div>} shadows className="bg-slate-50 rounded-xl">
            <color attach="background" args={['#f1f5f9']} />
            <ambientLight intensity={0.4} />
            <directionalLight position={[10, 10, 5]} intensity={1.2} castShadow shadow-mapSize={[1024, 1024]} />
            <pointLight position={[-5, 5, -5]} intensity={0.8} color="#fbbf24" />
            <OrbitControls autoRotate={showControls} autoRotateSpeed={2.0} enableZoom={true} enablePan={false} minDistance={2} maxDistance={12} target={[0, 0.8, 0]} makeDefault />
            <Float speed={1.5} floatIntensity={0.3}>
              <BookBox productId={productId} title={title} subtitle="Libreria San Martin 2026" />
            </Float>
          </Canvas>
        </CanvasErrorBoundary>
        <button onClick={() => setShowControls(!showControls)} className="absolute top-4 right-4 bg-white/80 backdrop-blur-sm text-xs px-3 py-1 rounded-full shadow-md hover:bg-white transition-all">
          {showControls ? 'Pausar rotación' : 'Auto-rotar'}
        </button>
      </div>
      <div className="bg-white p-4 rounded-xl border border-slate-200 mb-4">
        <h2 className="text-xl font-bold text-primary mb-2">{productInfo.title}</h2>
        <p className="text-sm text-slate-600">{productInfo.description}</p>
      </div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-center">
        <div className="bg-white p-3 rounded-lg border border-slate-200">
          <div className="text-xs text-slate-500">Categoria</div>
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
        <div className="bg-white p-3 rounded-lg border border-slate-200">
          <div className="text-xs text-slate-500">ID</div>
          <div className="font-semibold text-slate-700 text-sm">#{productInfo.id}</div>
        </div>
      </div>
      <div className="mt-4 flex items-center justify-center gap-4 text-xs text-slate-400">
        <span className="flex items-center gap-1">Arrastrar para rotar</span>
        <span className="flex items-center gap-1">Scroll para zoom</span>
        <span className="flex items-center gap-1">Posicionar sobre el libro</span>
      </div>
    </div>
  );
};

export default Product3DViewer;
