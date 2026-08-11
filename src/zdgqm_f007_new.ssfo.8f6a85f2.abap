DATA: lv_month TYPE tdlcount,
      lv_roman TYPE tdline, "char4,
      lv_plant TYPE char20.

lv_month = header-erdat+4(2).

CALL FUNCTION 'CONVERT_NUMBER'
  EXPORTING
    tdlcount   = lv_month
    tdnumberin = 'ROMAN'
    tdupper    = 'X'
    tdnumfixc  = '6'
    tdnumoutl  = '00'
  IMPORTING
    string     = lv_roman.

CASE header-mawerk.
  WHEN '0101'.
    lv_plant = 'TSP SLQ(PMG)'.
  WHEN '0102'.
    lv_plant = 'TSP CES(PMG)'.
  WHEN '0901'.
    lv_plant = 'SFF(PMG)'.
  WHEN '0401'.
    lv_plant = 'TNP(PMG)'.
  WHEN '3600' OR '3603'.
    lv_plant = 'KMM(BNMG)'.
  WHEN '3301'.
    lv_plant = 'PLI1(BNMG)'.
  WHEN '3302'.
    lv_plant = 'PLI2(BNMG)'.
  WHEN '2300'.
    lv_plant = 'RS(CPC)'.
  WHEN '1900'.
    lv_plant = 'TUS(CPC)'.
ENDCASE.

CONCATENATE header-qmnum 'QC' lv_plant lv_roman
  header-erdat(4) INTO gv_nomor SEPARATED BY '/'.











