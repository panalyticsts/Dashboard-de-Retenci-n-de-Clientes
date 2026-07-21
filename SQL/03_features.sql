-- ============================================================
-- 03_features.sql
-- Proyecto: Churn Telecom
-- Objetivo: crear tabla customers_features con variables derivadas
--           para alimentar el modelo Python y el dashboard Power BI
-- ============================================================

-- Consulta 3.1 — Crear tabla con todas las features
DROP TABLE IF EXISTS customers_features;
CREATE TABLE customers_features AS
SELECT
  -- === VARIABLES ORIGINALES ===
  customerID,
  gender,
  SeniorCitizen,
  Partner,
  Dependents,
  tenure,
  InternetService,
  Contract,
  PaperlessBilling,
  PaymentMethod,
  MonthlyCharges,
  TotalCharges,
  Churn,
  Churn_label,

  -- === FEATURE 1: Segmento de antigüedad ===
  -- Los primeros 12 meses son críticos para el churn
  CASE
    WHEN tenure BETWEEN 0 AND 12  THEN 'Nuevo (0-12m)'
    WHEN tenure BETWEEN 13 AND 36 THEN 'En desarrollo (13-36m)'
    WHEN tenure > 36              THEN 'Maduro (36m+)'
  END AS segmento_antiguedad,

  -- === FEATURE 2: Score de adopción de servicios ===
  -- Suma cuántos de los 6 servicios adicionales tiene el cliente
  (
    (CASE WHEN OnlineSecurity    = 'Yes' THEN 1 ELSE 0 END) +
    (CASE WHEN OnlineBackup      = 'Yes' THEN 1 ELSE 0 END) +
    (CASE WHEN DeviceProtection  = 'Yes' THEN 1 ELSE 0 END) +
    (CASE WHEN TechSupport       = 'Yes' THEN 1 ELSE 0 END) +
    (CASE WHEN StreamingTV       = 'Yes' THEN 1 ELSE 0 END) +
    (CASE WHEN StreamingMovies   = 'Yes' THEN 1 ELSE 0 END)
  ) AS score_servicios,

  -- === FEATURE 3: Ratio cargo mensual / antigüedad ===
  -- Cuánto paga por mes de permanencia (alto en clientes nuevos con plan costoso)
  CASE
    WHEN tenure = 0 THEN MonthlyCharges
    ELSE ROUND(MonthlyCharges / CAST(tenure AS REAL), 2)
  END AS ratio_cargo_antiguedad,

  -- === FEATURE 4: Segmento de valor (CLTV aproximado) ===
  -- Clasificación por ingreso total generado
  CASE
    WHEN TotalCharges < 500                 THEN 'Bajo'
    WHEN TotalCharges BETWEEN 500 AND 2000  THEN 'Medio'
    WHEN TotalCharges BETWEEN 2000 AND 5000 THEN 'Alto'
    ELSE 'Premium'
  END AS segmento_valor,

  -- === FEATURE 5: Flag de riesgo contractual ===
  -- Contrato mensual + sin servicios adicionales = máximo riesgo
  CASE
    WHEN Contract = 'Month-to-month' THEN 1
    ELSE 0
  END AS flag_contrato_mensual,

  -- === FEATURE 6: Método de pago de riesgo ===
  CASE
    WHEN PaymentMethod = 'Electronic check' THEN 1
    ELSE 0
  END AS flag_pago_riesgo,

  -- === FEATURE 7: CLTV proyectado (simple) ===
  -- Proyección a 24 meses: útil para priorizar intervenciones
  ROUND(MonthlyCharges * 24, 2) AS cltv_proyectado_24m

FROM customers_clean;

-- Verificar las nuevas columnas
SELECT * FROM customers_features LIMIT 5;
