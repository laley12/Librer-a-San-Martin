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
          <div className="flex items-center gap-4">
            <div className="text-right">
              <div className="text-sm font-semibold text-slate-700">
                {dashboardData.totalProducts}
              </div>
              <div className="text-xs text-slate-500">Productos</div>
            </div>
            <div className="text-right">
              <div className="text-sm font-semibold text-slate-700">
                {dashboardData.totalStock}
              </div>
              <div className="text-xs text-slate-500">Valor Stock</div>
            </div>
          </div>
        </div>
      </header>
