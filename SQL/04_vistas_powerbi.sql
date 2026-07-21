-- ============================================================
-- 04_vistas_powerbi.sql
-- Proyecto: Churn Telecom
-- Objetivo: vistas analíticas que se exportarán a CSV e
--           importarán directamente en Power BI
-- ============================================================

-- Vista 1 — Tasa de churn por segmento de contrato
CREATE VIEW IF NOT EXISTS v_churn_por_contrato AS
SELECT
  Contract,
  COUNT(*) AS total_clientes,
  SUM(Churn) AS clientes_churn,
  ROUND(SUM(Churn) * 100.0 / COUNT(*), 1) AS tasa_churn_pct
FROM customers_features
GROUP BY Contract
ORDER BY tasa_churn_pct DESC;

-- Vista 2 — Churn por tipo de internet y antigüedad
CREATE VIEW IF NOT EXISTS v_churn_internet_antiguedad AS
SELECT
  InternetService,
  segmento_antiguedad,
  COUNT(*) AS clientes,
  SUM(Churn) AS churn,
  ROUND(SUM(Churn) * 100.0 / COUNT(*), 1) AS tasa_churn_pct
FROM customers_features
GROUP BY InternetService, segmento_antiguedad
ORDER BY tasa_churn_pct DESC;

-- Vista 3 — Score de servicios vs churn (para gráfico de dispersión)
CREATE VIEW IF NOT EXISTS v_servicios_vs_churn AS
SELECT
  score_servicios,
  COUNT(*) AS clientes,
  SUM(Churn) AS clientes_churn,
  ROUND(SUM(Churn) * 100.0 / COUNT(*), 1) AS tasa_churn_pct,
  ROUND(AVG(MonthlyCharges), 2) AS cargo_promedio
FROM customers_features
GROUP BY score_servicios
ORDER BY score_servicios;

-- Vista 4 — Segmentos prioritarios por CLTV y riesgo
CREATE VIEW IF NOT EXISTS v_prioridad_retencion AS
SELECT
  segmento_valor,
  flag_contrato_mensual,
  COUNT(*) AS clientes,
  SUM(Churn) AS ya_abandonaron,
  ROUND(SUM(Churn) * 100.0 / COUNT(*), 1) AS tasa_churn_pct,
  ROUND(AVG(cltv_proyectado_24m), 0) AS cltv_promedio
FROM customers_features
GROUP BY segmento_valor, flag_contrato_mensual
ORDER BY tasa_churn_pct DESC, cltv_promedio DESC;
