*&---------------------------------------------------------------------*
*& Report ZCO_E011
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zco_e011.

TYPE-POOLS: slis.

INCLUDE zco_e011top.

SELECTION-SCREEN BEGIN OF BLOCK blxx WITH FRAME TITLE TEXT-dat.
PARAMETERS: p_tdform LIKE ssfscreen-fname DEFAULT 'ZCO_E011_SF001' NO-DISPLAY.
*            p_dest   LIKE tsp03-padest,
*            p_disp   LIKE ssfctrlop-preview  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK blxx.
*INCLUDE zabp_smartform.
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-dat.
PARAMETERS: p_bukrs  TYPE ce28010-bukrs OBLIGATORY,
            p_gsber  TYPE ce28010-gsber OBLIGATORY,
            p_mon(2) TYPE c OBLIGATORY,
            p_gjahr  TYPE ce28010-gjahr OBLIGATORY,
            p_prctr  TYPE ce28010-prctr OBLIGATORY,
            p_aufnr  TYPE ce28010-rkaufnr OBLIGATORY.

SELECT-OPTIONS: s_wwsec FOR ce28010-wwsec.
SELECTION-SCREEN END OF BLOCK data.

START-OF-SELECTION.
  PERFORM f_output_type.

  INCLUDE zco_e011f01.
