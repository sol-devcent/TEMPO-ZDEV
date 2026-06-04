FUNCTION zfm_opening_ending_stock.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(MATNR) TYPE  MATNR
*"     VALUE(WERKS) TYPE  WERKS_D
*"     VALUE(SPMON) TYPE  SPMON
*"  TABLES
*"      T_STOCK STRUCTURE  ZMS_OPENING_ENDING_STOCK
*"----------------------------------------------------------------------
  DATA: ld_spmon TYPE spmon.

  ld_spmon = sy-datum(6).

*- Get current stock
  SELECT matnr werks lgort labst insme speme
    INTO CORRESPONDING FIELDS OF TABLE gt_mard
    FROM mard WHERE matnr = matnr AND
                    werks = werks.

*- Get transaction until current
  SELECT spmon matnr werks lgort mzubb magbb
    INTO CORRESPONDING FIELDS OF TABLE gt_s031
    FROM s031 WHERE ssour = ' '         AND
                    vrsio = '000'       AND
                    spmon BETWEEN spmon AND ld_spmon AND
                    sptag = '00000000'  AND
                    spwoc = '000000'    AND
                    spbup = '000000'    AND
                    werks = werks       AND
                    matnr = matnr.

*- Get transaction period + 1 until current
  gt_s031a[] = gt_s031[].
  DELETE gt_s031a WHERE spmon NE spmon.

*- Calculate total current stock
  LOOP AT gt_mard.
    t_stock-matnr = gt_mard-matnr.
    t_stock-werks = gt_mard-werks.
    t_stock-lgort = gt_mard-lgort.
    t_stock-stkcur = gt_mard-labst + gt_mard-insme + gt_mard-speme.
    COLLECT t_stock. CLEAR t_stock.
  ENDLOOP.

*- Calculate total transaction until current
  LOOP AT gt_s031.
    t_stock-matnr = gt_s031-matnr.
    t_stock-werks = gt_s031-werks.
    t_stock-lgort = gt_s031-lgort.
    t_stock-mzubb = gt_s031-mzubb.
    t_stock-magbb = gt_s031-magbb.
    COLLECT t_stock. CLEAR t_stock.
  ENDLOOP.

*- Calculate total transaction period + 1 until current
  LOOP AT gt_s031a.
    t_stock-matnr = gt_s031a-matnr.
    t_stock-werks = gt_s031a-werks.
    t_stock-lgort = gt_s031a-lgort.
    t_stock-mzubb2 = gt_s031a-mzubb.
    t_stock-magbb2 = gt_s031a-magbb.
    COLLECT t_stock. CLEAR t_stock.
  ENDLOOP.

*- Calculate open & ending stock
  LOOP AT t_stock.
    t_stock-stkopn = t_stock-stkcur - t_stock-mzubb + t_stock-magbb.
    t_stock-stkend = t_stock-stkopn + t_stock-mzubb2 - t_stock-magbb2.
    MODIFY t_stock TRANSPORTING stkopn stkend.
  ENDLOOP.
ENDFUNCTION.
