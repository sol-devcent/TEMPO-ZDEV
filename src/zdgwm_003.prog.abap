*&---------------------------------------------------------------------*
*& Report  ZDGWM_003
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zdgwm_003.

*&---------------------------------------------------------------------*
*&      Form  F_WERKS
*&---------------------------------------------------------------------*
FORM f_werks TABLES i_input  STRUCTURE itcsy
                    i_output STRUCTURE itcsy.
  DATA : v_werks       TYPE werks_d,
         v_lgort       TYPE lgort_d,
         v_name1w      TYPE name1_gp,
         v_drukz       TYPE lvs_drukz,
         v_druck       TYPE ltak_druck,
         v_reprint(10),
         v_lgnum       TYPE lgnum,
         v_tanum       TYPE tanum,
         v_judul(50).

  LOOP AT i_input.
    CASE i_input-name.
      WHEN 'LTAP-WERKS'.
        MOVE i_input-value TO v_werks.
      WHEN 'LTAP-LGORT'.
        MOVE i_input-value TO v_lgort.
      WHEN 'LTAK-LGNUM'.
        MOVE i_input-value TO v_lgnum.
      WHEN 'LTAK-TANUM'.
        MOVE i_input-value TO v_tanum.
      WHEN 'LTAK-DRUKZ'.
        MOVE i_input-value TO v_drukz.
      WHEN 'LTAK-DRUCK'.
        MOVE i_input-value TO v_druck.
    ENDCASE.
  ENDLOOP.

  IF v_werks EQ '0501'.
    SELECT SINGLE name1
      FROM twlad AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
      INTO v_name1w
      WHERE werks EQ v_werks AND
            lgort EQ v_lgort.
  ELSE.
    SELECT SINGLE butxt
      FROM t001k AS a JOIN t001 AS b ON a~bukrs EQ b~bukrs
      INTO v_name1w
      WHERE bwkey EQ v_werks.
  ENDIF.

  SELECT SINGLE drukz
    FROM ltak
    INTO v_drukz
    WHERE lgnum EQ v_lgnum
      AND tanum EQ v_tanum.

  IF v_drukz EQ '45'.
    IF v_druck EQ 'X'.
      v_reprint = 'REPRINT'.
    ENDIF.
  ELSE.
    UPDATE ltak SET drukz = '45'
                WHERE lgnum EQ v_lgnum
                  AND tanum EQ v_tanum.
  ENDIF.

  IF v_lgnum = '051' OR
    v_lgnum(1) = 'C'.
    v_judul = 'GOODS RECEIPT LABEL'.
  ENDIF.

  LOOP AT i_output.
    CASE i_output-name.
      WHEN 'V_NAME1W'.
        MOVE v_name1w TO i_output-value.
      WHEN 'V_REPRINT'.
        MOVE v_reprint TO i_output-value.
      WHEN 'V_JUDUL'.
        MOVE v_judul TO i_output-value.
    ENDCASE.
    MODIFY i_output.
  ENDLOOP.
ENDFORM .                    "F_WERKS

*&---------------------------------------------------------------------*
*&      Form  F_MSEG
*&---------------------------------------------------------------------*
FORM f_mseg TABLES i_input  STRUCTURE itcsy
                   i_output STRUCTURE itcsy.
  DATA : v_mblnr TYPE mblnr,
         v_mjahr TYPE mjahr,
         v_lifnr TYPE lifnr,
         v_hsdat TYPE hsdat,
         v_name1 TYPE name1_gp,
         v_matnr TYPE matnr.

  DATA : lt_mseg    TYPE STANDARD TABLE OF mseg.

  LOOP AT i_input.
    CASE i_input-name.
      WHEN 'LTAK-MBLNR'.
        MOVE i_input-value TO v_mblnr.
      WHEN 'LTAK-MJAHR'.
        MOVE i_input-value TO v_mjahr.
      WHEN 'LTAP-MATNR'.
        MOVE i_input-value TO v_matnr.
    ENDCASE.
  ENDLOOP.

*  SELECT SINGLE lifnr hsdat
*    FROM mseg
*    INTO (v_lifnr, v_hsdat)
*    WHERE mblnr = v_mblnr
*      AND mjahr = v_mjahr.

  SELECT SINGLE lifnr hsdat
    FROM mseg
    INTO (v_lifnr, v_hsdat)
    WHERE mblnr = v_mblnr
      AND mjahr = v_mjahr
      AND matnr = v_matnr.

  IF v_lifnr IS NOT INITIAL.
    SELECT SINGLE name1
      FROM lfa1
      INTO v_name1
      WHERE lifnr = v_lifnr.
  ENDIF.

*  v_hsdat = '20230223'.

  LOOP AT i_output.
    CASE i_output-name.
      WHEN 'V_NAME1'.
        MOVE v_name1 TO i_output-value.
      WHEN 'V_HSDAT'.
        WRITE v_hsdat TO i_output-value DD/MM/YYYY.
    ENDCASE.
    MODIFY i_output.
  ENDLOOP.
ENDFORM .                    "F_MSEG

*&---------------------------------------------------------------------*
*&      Form  F_QUANTITY
*&---------------------------------------------------------------------*
FORM f_quantity TABLES i_input  STRUCTURE itcsy
                       i_output STRUCTURE itcsy.
  DATA : lt_ltap LIKE ltap OCCURS 0 WITH HEADER LINE.
  DATA : v_lgnum       TYPE lgnum,
         v_tanum       TYPE tanum,
         v_matnr       TYPE matnr,
         v_vsola       TYPE ltap_vsola,
         v_altme       TYPE lrmei,
         v_carton      TYPE i,
         v_cartont(50),
         v_vsolat(50).

  LOOP AT i_input.
    CASE i_input-name.
      WHEN 'LTAK-LGNUM'.
        MOVE i_input-value TO v_lgnum.
      WHEN 'LTAK-TANUM'.
        MOVE i_input-value TO v_tanum.
      WHEN 'LTAP-MATNR'.
        MOVE i_input-value TO v_matnr.
      WHEN 'LTAP-VSOLA'.
        MOVE i_input-value TO v_vsola.
      WHEN 'LTAP-ALTME'.
        MOVE i_input-value TO v_altme.
    ENDCASE.
  ENDLOOP.

  BREAK bcdik.
  CLEAR v_vsola.

  SELECT lgnum tanum tapos vsola
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE lt_ltap
    WHERE lgnum = v_lgnum
      AND tanum = v_tanum.

  LOOP AT lt_ltap.
    ADD lt_ltap-vsola TO v_vsola.
  ENDLOOP.

*  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
*    EXPORTING
*      input          = v_altme
*      language       = sy-langu
*    IMPORTING
*      output         = v_altme
*    EXCEPTIONS
*      unit_not_found = 1
*      OTHERS         = 2.

  WRITE v_vsola TO v_vsolat UNIT v_altme.
  CONDENSE v_vsolat NO-GAPS.
  CONCATENATE v_vsolat v_altme INTO v_vsolat SEPARATED BY space.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr              = v_matnr
      i_in_me              = v_altme
      i_out_me             = 'KAR'
      i_menge              = v_vsola
    IMPORTING
      e_menge              = v_vsola
    EXCEPTIONS
      error_in_application = 1
      error                = 2
      OTHERS               = 3.

  v_carton  = ceil( v_vsola ).

  WRITE v_carton TO v_cartont UNIT 'KAR'.
  CONDENSE v_cartont NO-GAPS.
  CONCATENATE v_cartont 'CAR' INTO v_cartont SEPARATED BY space.

  LOOP AT i_output.
    CASE i_output-name.
      WHEN 'V_VSOLAT'.
        MOVE v_vsolat TO i_output-value.
      WHEN 'V_CARTONT'.
        MOVE v_cartont TO i_output-value.
    ENDCASE.
    MODIFY i_output.
  ENDLOOP.
ENDFORM .                    "F_QUANTITY

*&---------------------------------------------------------------------*
*&      Form  F_LICHAPRUE
*&---------------------------------------------------------------------*
FORM f_lichaprue TABLES i_input  STRUCTURE itcsy
                        i_output STRUCTURE itcsy.
  DATA : v_matnr        TYPE matnr,
         v_charg        TYPE charg_d,
         v_licha        TYPE lichn,
         v_nltyp        TYPE ltap-nltyp,
         v_lgnum        TYPE ltak-lgnum,
         v_zeugn        TYPE ltap-zeugn,
         v_prueflos(12),
         v_flag,
         v_name1        TYPE kna1-name1.

  DATA : lr_lgtyp TYPE RANGE OF lgtyp,
         ls_ekpo  TYPE ekpo.

  DATA : lv_count   TYPE i.

  LOOP AT i_input.
    CASE i_input-name.
      WHEN 'LTAK-LGNUM'.
        MOVE i_input-value TO v_lgnum.
      WHEN 'LTAP-MATNR'.
        MOVE i_input-value TO v_matnr.
      WHEN 'LTAP-CHARG'.
        MOVE i_input-value TO v_charg.
      WHEN 'LTAP-NLTYP'.
        MOVE i_input-value TO v_nltyp.
      WHEN 'LTAP-ZEUGN'.
        MOVE i_input-value TO v_zeugn.
    ENDCASE.
  ENDLOOP.

  CALL FUNCTION 'ZDSC_FM001'
    EXPORTING
      pi_lgnum = v_lgnum
    TABLES
      pt_lgtyp = lr_lgtyp.

  SELECT SINGLE licha
    FROM mch1
    INTO v_licha
    WHERE matnr = v_matnr
      AND charg = v_charg.
  IF sy-subrc <> 0.
    v_licha = 'N/A'.
  ENDIF.

  IF lr_lgtyp[] IS NOT INITIAL.
    IF v_nltyp IN lr_lgtyp.
      v_flag  = 'X'.
      SELECT SINGLE name1
        FROM ekpo JOIN kna1 ON ekpo~kunnr EQ kna1~kunnr
        INTO v_name1
        WHERE ebeln EQ v_zeugn.
    ELSE.
      v_prueflos  = 'N/A'.
    ENDIF.
  ELSE.
    v_prueflos  = 'N/A'.
  ENDIF.

  LOOP AT i_output.
    CASE i_output-name.
      WHEN 'V_LICHA'.
        MOVE v_licha TO i_output-value.
      WHEN 'V_PRUEFLOS'.
        MOVE v_prueflos TO i_output-value.
      WHEN 'V_NAME1'.
        MOVE v_name1 TO i_output-value.
      WHEN 'V_FLAG'.
        MOVE v_flag TO i_output-value.
    ENDCASE.
    MODIFY i_output.
  ENDLOOP.
ENDFORM .                    "F_LICHAPRUE

*&---------------------------------------------------------------------*
*&      Form  F_QRCODE
*&---------------------------------------------------------------------*
FORM f_qrcode TABLES i_input  STRUCTURE itcsy
                     i_output STRUCTURE itcsy.
  DATA : v_lznum       TYPE ltak-lznum,
         v_lgnum       TYPE lgnum,
         v_tanum       TYPE tanum,
         v_qrcode(255).

  LOOP AT i_input.
    CASE i_input-name.
      WHEN 'LTAK-LGNUM'.
        MOVE i_input-value TO v_lgnum.
      WHEN 'LTAK-LZNUM'.
        MOVE i_input-value TO v_lznum.
      WHEN 'LTAK-TANUM'.
        MOVE i_input-value TO v_tanum.
    ENDCASE.
  ENDLOOP.

  IF v_lgnum(1) = 'C'.
    CONCATENATE v_lznum ';' v_tanum
    INTO v_qrcode.
  ENDIF.

  LOOP AT i_output.
    CASE i_output-name.
      WHEN 'V_QRCODE'.
        MOVE v_qrcode TO i_output-value.
    ENDCASE.
    MODIFY i_output.
  ENDLOOP.
ENDFORM .                    "F_QRCODE
