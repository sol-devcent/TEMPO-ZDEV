DATA : ls_dpp   TYPE zproject.

SELECT SINGLE *
  FROM zproject
  INTO CORRESPONDING FIELDS OF ls_dpp
  WHERE name = 'DPP12'.

IF t_header-fkdat > ls_Dpp-datab.
  gv_ppn = '12'.
ELSE.
  gv_ppn = '11'.
ENDIF.






















