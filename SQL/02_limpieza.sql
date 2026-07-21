-- ============================================================
-- 02_limpieza.sql
-- Proyecto: Churn Telecom
-- Objetivo: crear tabla customers_clean a partir de customers_raw,
--           con tipos correctos y sin registros problemáticos
-- ============================================================

-- Consulta 2.1 — Crear tabla limpia con conversiones de tipo
DROP TABLE IF EXISTS customers_clean;
CREATE TABLE customers_clean AS
SELECT
  customerID,
  gender,
  CAST(SeniorCitizen AS INTEGER)       AS SeniorCitizen,
  Partner,
  Dependents,
  CAST(tenure AS INTEGER)              AS tenure,
  PhoneService,
  MultipleLines,
  InternetService,
  OnlineSecurity,
  OnlineBackup,
  DeviceProtection,
  TechSupport,
  StreamingTV,
  StreamingMovies,
  Contract,
  PaperlessBilling,
  PaymentMethod,
  CAST(MonthlyCharges AS REAL)         AS MonthlyCharges,
  -- Convertir TotalCharges a número; los vacíos se reemplazan por MonthlyCharges
  CASE
    WHEN TRIM(TotalCharges) = '' OR TotalCharges IS NULL
    THEN CAST(MonthlyCharges AS REAL)
    ELSE CAST(TotalCharges AS REAL)
  END                                  AS TotalCharges,
  -- Convertir Churn a numérico para modelado
  CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END AS Churn,
  Churn AS Churn_label
FROM customers_raw
WHERE customerID IS NOT NULL
  AND TRIM(customerID) != '';

-- Verificar resultado
SELECT COUNT(*) AS total_clean FROM customers_clean;
-- Esperado: 7043 (todos, porque los 11 casos se imputaron)

-- Consulta 2.2 — Verificar que no quedan nulos
-- Contar nulos por columna crítica
SELECT
  SUM(CASE WHEN customerID IS NULL THEN 1 ELSE 0 END)       AS null_id,
  SUM(CASE WHEN tenure IS NULL THEN 1 ELSE 0 END)           AS null_tenure,
  SUM(CASE WHEN MonthlyCharges IS NULL THEN 1 ELSE 0 END)   AS null_monthly,
  SUM(CASE WHEN TotalCharges IS NULL THEN 1 ELSE 0 END)     AS null_total
FROM customers_clean;
-- Todo debe ser 0
