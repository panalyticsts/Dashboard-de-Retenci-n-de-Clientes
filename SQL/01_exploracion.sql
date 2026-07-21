-- ============================================================
-- 01_exploracion.sql
-- Proyecto: Churn Telecom
-- Objetivo: consultas de reconocimiento del dataset customers_raw
-- ============================================================

-- Consulta 1.1 — Contar filas y verificar carga
-- Verificar cantidad de registros cargados
SELECT COUNT(*) AS total_clientes FROM customers_raw;
-- Resultado esperado: 7043

-- Consulta 1.2 — Revisar valores únicos de la variable objetivo
-- Distribución de churn (variable objetivo)
SELECT Churn,
       COUNT(*) AS cantidad,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers_raw), 2) AS porcentaje
FROM customers_raw
GROUP BY Churn;
-- Esperado: Yes ~26.5%, No ~73.5%

-- Consulta 1.3 — Detectar el problema en TotalCharges
-- TotalCharges tiene espacios vacíos (no son NULL reales)
SELECT COUNT(*) AS registros_con_problema
FROM customers_raw
WHERE TRIM(TotalCharges) = '' OR TotalCharges IS NULL;
-- Esperado: 11 registros problemáticos

-- Consulta 1.4 — Distribución por tipo de contrato
SELECT Contract,
       COUNT(*) AS clientes,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers_raw), 1) AS pct
FROM customers_raw
GROUP BY Contract
ORDER BY clientes DESC;
