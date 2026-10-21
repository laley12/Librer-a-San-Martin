/**
 * ============================================================
 * main.jsx - Entrada principal del Frontend React/Vite
 * Librería San Martín - Tarea 6
 * ============================================================
 */

import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import './index.css';

// Configurar encabezados personalizados si es necesario
if (import.meta.env.VITE_API_URL) {
  console.log('[Frontend] API URL:', import.meta.env.VITE_API_URL);
}

// Estado global de la aplicación
const initialState = {
  user: null,
  isAuthenticated: false,
  products: [],
  loading: false,
  error: null,
};

function AppWrapper() {
  return (
    <React.StrictMode>
      <App />
    </React.StrictMode>
  );
}

// Renderizar la aplicación
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<AppWrapper />);

console.log('[Frontend] ✅ App React/Vite cargada correctamente');
console.log('[Frontend] 📦 Tarea 6 - Nuevas Tecnologías implementada');
