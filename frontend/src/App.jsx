/**
 * ============================================================
 * App.jsx - Componente raíz de la SPA
 * Librería San Martín - Tarea 6
 * ============================================================
 */

import React, { useState, useEffect } from 'react';
import Product3DViewer from './components/Product3DViewer';

/**
 * App principal - Dashboard de la Librería San Martín
 */
function App() {
  const [dashboardData, setDashboardData] = useState({
    totalProducts: 0,
    totalStock: 'Bs 0.00',
    totalValue: 0,
    lastSale: '—',
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Simular carga de datos del dashboard
    const timer = setTimeout(() => {
      setDashboardData({
        totalProducts: 142,
        totalStock: 'Bs 2,847,500.00',
        totalValue: 2847500,
        lastSale: 'Hace 5 min · 3 ventas',
      });
      setLoading(false);
    }, 800);

    return () => clearTimeout(timer);
  }, []);

  return (
    <div className="min-h-screen flex flex-col">
      {/* Header */}

      {/* Contenido principal */}
      <main className="flex-1 p-6 grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Sección 3D Viewer (2/3) */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-5">
            <h2 className="text-lg font-semibold text-primary mb-4">
              📖 Visualizador 3D de Productos
            </h2>
            <p className="text-sm text-slate-500 mb-4">
              Caja de libro interactiva que rota con el mouse.
              Técnicas: Three.js + @react-three/fiber
            </p>
            <Product3DViewer />
          </div>
        </div>

        {/* Sección Productos & Inventario */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
            <h2 className="text-lg font-semibold text-primary mb-4">
              📦 Productos & Inventario
            </h2>
            
            {/* Estadísticas rápidas */}
            <div className="grid grid-cols-2 gap-3 mb-4">
              <div className="bg-slate-50 rounded-lg p-2">
                <div className="font-medium text-sm text-slate-500">Productos total</div>
                <div className="text-xl font-bold text-primary">142</div>
              </div>
              <div className="bg-slate-50 rounded-lg p-2">
                <div className="font-medium text-sm text-slate-500">Stock total</div>
                <div className="text-xl font-bold text-green-600">Bs 2,847,500.00</div>
              </div>
            </div>

            {/* Lista de productos con stock bajo */}
            <div className="mt-4">
              <h3 className="text-sm font-medium text-primary mb-2">Productos en stock</h3>
              <ul className="space-y-1 text-sm">
                <li className="flex items-center gap-2 px-2 py-1 bg-slate-50 rounded-lg">
                  <span className="w-2 h-2 rounded-full bg-green-500"></span>
                  <span>0001 - Juguetes Astrolabio</span>
                </li>
                <li className="flex items-center gap-2 px-2 py-1 bg-slate-50 rounded-lg">
                  <span className="w-2 h-2 rounded-full bg-green-500"></span>
                  <span>0002 - Juguetes Carablanca</span>
                </li>
                <li className="flex items-center gap-2 px-2 py-1 bg-slate-50 rounded-lg">
                  <span className="w-2 h-2 rounded-full bg-yellow-400"></span>
                  <span>0003 - Juguetes Árbol Genético</span>
                </li>
              </ul>
            </div>

            {/* Resumen de discrepancias */}
            <div className="mt-4 p-3 bg-slate-50 rounded-lg">
              <h3 className="text-xs font-medium text-primary mb-2">Resumen</h3>
              <div className="flex items-center gap-2">
                <span className="px-2 py-1 text-xs font-semibold bg-red-100 text-red-600 rounded-full">3</span>
                <span>Productos mínimos</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="px-2 py-1 text-xs font-semibold bg-yellow-100 text-yellow-600 rounded-full">2</span>
                <span>Agotados</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="px-2 py-1 text-xs font-semibold bg-green-100 text-green-600 rounded-full">OK</span>
                <span>Inventario ok</span>
              </div>
            </div>
          </div>
        </div>

        {/* Sección lateral: Resumen de Discrepancias */}
        <div className="space-y-6">
          <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-5">
            <h2 className="text-lg font-semibold text-primary mb-4">
              📋 Resumen de Discrepancias
            </h2>
            <div className="space-y-4">
              <div className="flex items-center justify-between p-3 bg-slate-50 rounded-lg">
                <div>
                  <div className="font-medium text-sm">Productos mínimos</div>
                  <div className="text-xs text-slate-500">0001, 0002, 0003</div>
                </div>
                <span className="px-2 py-1 text-xs font-semibold bg-red-100 text-red-600 rounded-full">
                  3
                </span>
              </div>
              <div className="flex items-center justify-between p-3 bg-slate-50 rounded-lg">
                <div>
                  <div className="font-medium text-sm">Agotados</div>
                  <div className="text-xs text-slate-500">0004, 0005</div>
                </div>
                <span className="px-2 py-1 text-xs font-semibold bg-yellow-100 text-yellow-600 rounded-full">
                  2
                </span>
              </div>
              <div className="flex items-center justify-between p-3 bg-slate-50 rounded-lg">
                <div>
                  <div className="font-medium text-sm">Inventario ok</div>
                  <div className="text-xs text-slate-500">Resto del catálogo</div>
                </div>
                <span className="px-2 py-1 text-xs font-semibold bg-green-100 text-green-600 rounded-full">
                  OK
                </span>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-5">
            <h3 className="text-sm font-semibold text-primary mb-3">
              📦 Productos Requeridos
            </h3>
            <ul className="space-y-2 text-sm">
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-red-400"></span>
                <span className="text-slate-600">0001 - Juguetes Astrolabio</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-red-400"></span>
                <span className="text-slate-600">0002 - Juguetes Carablanca</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-red-400"></span>
                <span className="text-slate-600">0003 - Juguetes Árbol Genético</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-yellow-400"></span>
                <span className="text-slate-600">0004 - Juguetes Set Pizarra</span>
              </li>
              <li className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-yellow-400"></span>
                <span className="text-slate-600">0005 - Juguetes Mesa Mural</span>
              </li>
            </ul>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-slate-200 px-6 py-3 text-xs text-slate-400">
        <span>Tarea 6 — Nuevas Tecnologías · Librería San Martín</span>
      </footer>
    </div>
  );
}

export default App;

      {/* Header con foto de perfil de Jeremy */}
      <header className="bg-white border-b border-slate-200 px-6 py-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-primary">
              📚 Librería San Martín
            </h1>
            <p className="text-sm text-slate-500 mt-1">
              Dashboard General · Tarea 6 · Nuevas Tecnologías
            </p>
          </div>

          {/* Foto de perfil de Jeremy - recuperada de la versión web/PHP */}
          <div className="flex items-center gap-2">
            {/* Foto real en lugar de círculo con iniciales JE */}
            <img
              src="/assets/avatar_jeremy.png"
              alt="Jeremy"
              className="w-8 h-8 rounded-full object-cover border-2 border-slate-100"
            />
            {/* Fallback: iniciales si la imagen no carga */}
            <span
              className="w-8 h-8 rounded-full bg-slate-200 flex items-center justify-center text-xs text-slate-500 flex-shrink-0"
              style={{ display: 'block' }}
            >
              JE
            </span>
          </div>
        </div>
      </header>
