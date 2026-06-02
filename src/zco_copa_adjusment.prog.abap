*&---------------------------------------------------------------------*
*& Report  ZCO_COPA_ADJUSMENT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zco_copa_adjusment NO STANDARD PAGE HEADING.

INCLUDE zco_copa_adjusment_top.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE TEXT-001.
PARAMETERS: p_bukrs LIKE ce18010-bukrs MODIF ID buk,
            p_perio LIKE ce18010-perio MODIF ID per,
            p_gsber LIKE ce18010-gsber MODIF ID gsb.
SELECTION-SCREEN SKIP.
PARAMETERS: p_post RADIOBUTTON GROUP grp1 USER-COMMAND us1,
            p_revs RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK general.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen.
    WHEN space.
      PERFORM f_validate_screen.
  ENDCASE.

INITIALIZATION.
  p_bukrs = '8010'.
  CONCATENATE sy-datum(4) '0' sy-datum+4(2) INTO p_perio.

START-OF-SELECTION.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zco_copa_adjusment_cl1.
  INCLUDE zco_copa_adjusment_f01.
