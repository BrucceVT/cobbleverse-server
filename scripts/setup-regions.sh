#!/bin/bash
# ──────────────────────────────────────────────────
# setup-regions.sh — Auto-triggers region structure 
# generation via RCON para Cobbleverse.
# ──────────────────────────────────────────────────
# Ejecutar SOLO cuando el servidor esté completamente
# encendido y sin jugadores (causa lag temporal por
# generación masiva de estructuras).
# ──────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

CONTAINER="cobbleverse"

if ! docker ps | grep -q "${CONTAINER}"; then
  echo "❌ El contenedor '${CONTAINER}' no está corriendo."
  echo "Primero levanta el servidor con ./scripts/up.sh"
  exit 1
fi

echo "🌍 Iniciando generación de regiones (Kanto, Johto, Hoenn, Sinnoh)..."
echo "⚠️ Esto causará MUCHO lag temporal. Espera a que termine cada región."

REGIONS=("kanto" "johto" "hoenn" "sinnoh")

for REGION in "${REGIONS[@]}"; do
  echo "────────────────────────────────────────"
  echo "▶️ Generando: ${REGION^}..."
  docker exec -i "${CONTAINER}" rcon-cli "function setup:${REGION}"
  
  echo "⏳ Esperando 15 segundos para que los chunks se estabilicen..."
  sleep 15
done

echo "────────────────────────────────────────"
echo "✅ ¡Todas las regiones han sido generadas!"
