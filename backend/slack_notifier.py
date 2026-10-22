"""
==============================================================================
SLACK NOTIFIER - backend/slack_notifier.py
==============================================================================
Función auxiliar para enviar notificaciones a Slack cada vez que un
producto nuevo sea registrado o modificado en el sistema.

Configuración:
--------------
- La URL del webhook se obtiene de la variable de entorno SLACK_WEBHOOK_URL
  (definida en el archivo .env de la raíz del proyecto).

Uso:
----
    from slack_notifier import notify_new_product

    producto = {"id": 1, "nombre": "Cuaderno 100 Hojas", "precio": 6.50, "stock": 50, "categoria": "Escolar y Papelería"}
    notify_new_product(producto)

Dependencias:
-------------
    pip install requests

@author: Devin AI & Antigravity - Tarea 6 Librería San Martín
==============================================================================
"""

import os
import json
import requests
from typing import Dict, Any, Optional
from datetime import datetime

# Cargar configuración desde el .env
SLACK_WEBHOOK_URL: Optional[str] = os.getenv("SLACK_WEBHOOK_URL")

# URL base de la API
VITE_API_URL: Optional[str] = os.getenv("VITE_API_URL", "https://libreria-san-martin.vercel.app/api/v1")


def notify_new_product(
    product: Dict[str, Any],
    webhook_url: Optional[str] = None,
    env: str = "production"
) -> Dict[str, Any]:
    """
    Envía una notificación a Slack cuando se registra un nuevo producto.

    Args:
        product: Diccionario con los datos del producto
        webhook_url: URL opcional (por defecto usa SLACK_WEBHOOK_URL)
        env: Entorno (development, staging, production)

    Returns:
        Dict con el estado de la operación
    """
    if webhook_url is None:
        webhook_url = SLACK_WEBHOOK_URL

    if not webhook_url:
        return {
            "success": False,
            "error": "SLACK_WEBHOOK_URL no está configurada",
            "product": product,
        }

    # Preparar datos del producto
    product_name = product.get("nombre", "Producto sin nombre")
    category = product.get("categoria", "Sin categoría")
    price = product.get("precio", product.get("precio_venta", "Precio no disponible"))
    stock = product.get("stock", "Stock no disponible")

    if isinstance(price, (int, float)):
        price_str = f"Bs {price:,.2f}"
    else:
        price_str = str(price)

    # Crear bloques Slack Blocks modernos
    blocks = [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "🚀 Nuevo Producto Registrado · Librería San Martín",
                "emoji": True
            }
        },
        {
            "type": "section",
            "fields": [
                {
                    "type": "mrkdwn",
                    "text": f"*Producto:*\n{product_name}"
                },
                {
                    "type": "mrkdwn",
                    "text": f"*Categoría:*\n`{category}`"
                },
                {
                    "type": "mrkdwn",
                    "text": f"*Precio de Venta:*\n{price_str}"
                },
                {
                    "type": "mrkdwn",
                    "text": f"*Stock Inicial:*\n{stock} unidades"
                }
            ]
        },
        {
            "type": "divider"
        },
        {
            "type": "context",
            "elements": [
                {
                    "type": "mrkdwn",
                    "text": f"🏷️ *ID:* `{product.get('id', 'N/A')}` · 📍 *Entorno:* `{env}` · ⏱️ *Fecha:* {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
                }
            ]
        }
    ]

    payload: Dict[str, Any] = {
        "text": f"Nuevo producto registrado: {product_name} ({price_str})",
        "blocks": blocks,
        "username": "Librería San Martín Bot",
        "icon_emoji": ":books:"
    }

    try:
        response = requests.post(
            webhook_url,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=10
        )

        # Log opcional de auditoría
        if VITE_API_URL and response.status_code == 200:
            try:
                audit_payload = {
                    "event": "product.create",
                    "product_id": product.get("id"),
                    "product_name": product_name,
                    "timestamp": datetime.now().isoformat(),
                }
                requests.post(
                    f"{VITE_API_URL}/audits",
                    json=audit_payload,
                    timeout=5
                )
            except Exception:
                pass

        return {
            "success": response.status_code == 200,
            "status_code": response.status_code,
            "product": product,
        }

    except requests.exceptions.Timeout:
        return {
            "success": False,
            "error": "Timeout enviando alerta a Slack",
            "product": product,
        }
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": str(e),
            "product": product,
        }


def notify_product_update(
    product_id: int,
    old_data: Dict[str, Any],
    new_data: Dict[str, Any],
    webhook_url: Optional[str] = None
) -> Dict[str, Any]:
    """
    Notifica cuando un producto es modificado.
    """
    if webhook_url is None:
        webhook_url = SLACK_WEBHOOK_URL

    if not webhook_url:
        return {"success": False, "error": "SLACK_WEBHOOK_URL no está configurada"}

    changes = []
    for key in set(list(old_data.keys()) + list(new_data.keys())):
        old_val = old_data.get(key, "—")
        new_val = new_data.get(key, "—")
        if str(old_val) != str(new_val):
            changes.append(f"`{key}`: {old_val} → {new_val}")

    if not changes:
        return {"success": False, "error": "No hay cambios detectados", "product_id": product_id}

    product_name = new_data.get("nombre", "Producto sin nombre")

    blocks = [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "📝 Producto Actualizado · Librería San Martín",
                "emoji": True
            }
        },
        {
            "type": "section",
            "fields": [
                {
                    "type": "mrkdwn",
                    "text": f"*Producto:*\n{product_name}"
                },
                {
                    "type": "mrkdwn",
                    "text": f"*Cambios:*\n" + "\n".join([f"• {c}" for c in changes])
                }
            ]
        },
        {
            "type": "context",
            "elements": [
                {
                    "type": "mrkdwn",
                    "text": f"ID: `{product_id}` · Actualizado el {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
                }
            ]
        }
    ]

    payload: Dict[str, Any] = {
        "text": f"Producto modificado: {product_name}",
        "blocks": blocks,
        "username": "Librería San Martín Bot",
        "icon_emoji": ":pencil2:"
    }

    try:
        response = requests.post(
            webhook_url,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        return {
            "success": response.status_code == 200,
            "status_code": response.status_code,
            "product_id": product_id,
        }
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": str(e),
            "product_id": product_id,
        }


def notify_deploy(env: str = "production", branch: str = "main") -> Dict[str, Any]:
    """
    Notifica cuando se completa un despliegue (Vercel/Render).
    """
    if not SLACK_WEBHOOK_URL:
        return {"success": False, "error": "SLACK_WEBHOOK_URL no está configurada"}

    blocks = [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "🚀 Despliegue Completado · Librería San Martín",
                "emoji": True
            }
        },
        {
            "type": "section",
            "fields": [
                {
                    "type": "mrkdwn",
                    "text": f"*Entorno:* `{env}`"
                },
                {
                    "type": "mrkdwn",
                    "text": f"*Rama:* `{branch}`"
                },
                {
                    "type": "mrkdwn",
                    "text": "*URL de Despliegue:*\n<https://libreria-san-martin.vercel.app|libreria-san-martin.vercel.app>"
                }
            ]
        }
    ]

    payload: Dict[str, Any] = {
        "text": f"Despliegue completado con éxito en {env} ({branch})",
        "blocks": blocks,
        "username": "Librería San Martín Bot",
        "icon_emoji": ":rocket:"
    }

    try:
        response = requests.post(
            SLACK_WEBHOOK_URL,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        return {
            "success": response.status_code == 200,
            "status_code": response.status_code,
            "env": env,
        }
    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "error": str(e),
            "env": env,
        }
