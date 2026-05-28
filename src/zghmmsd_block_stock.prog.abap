*&---------------------------------------------------------------------*
*& Program Name     : ZGHMMSD_BLOCK_STOCK                              *
*& Module Name      : SD                                               *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : dd/mm/yyyy                                       *
*& Program Type     : Enhancement                                      *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : xxxxxxxxxx xx xxxxxx xxxxxxx xxxx xxxx xxxxx     *
*&                    xxxx xx xxxxxxx xxxx xx xx xx xxxxxxxxx          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zghmmsd_block_stock
               NO STANDARD PAGE HEADING
               LINE-SIZE 255.

*------------------standard common includes----------------------------*
* Authorization checking macros
*INCLUDE zabp_atz.

* Upload and download flat file macors
*INCLUDE zabp_udf.
* common report header and other functions
INCLUDE zabp_header.

* ALV common functions
INCLUDE zabp_alv_common.

*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zghmmsd_block_stocktop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.

PARAMETERS: p_vkorg LIKE knvv-vkorg DEFAULT '8020' MODIF ID 001,
            p_vtweg LIKE knvv-vtweg DEFAULT '10' MODIF ID 001.
*            p_lgort like mard-lgort default 1000.
SELECT-OPTIONS: s_lgort FOR mard-lgort DEFAULT 1000 NO INTERVALS MODIF ID 001,
                s_werks FOR t001w-werks MODIF ID 001,
*               s_vkbur for knvv-vkbur, " OBLIGATORY,
               s_matnr FOR marc-matnr MODIF ID 001.
PARAMETERS: p_date LIKE sy-datum MODIF ID 001.
PARAMETERS: vrsio LIKE rmcs4-cmvrsioq OBLIGATORY DEFAULT '&(' MODIF ID 001.
SELECTION-SCREEN  SKIP 1.
PARAMETERS: p_vari  LIKE disvariant-variant MODIF ID 001.

SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN :
  BEGIN OF BLOCK frm WITH FRAME TITLE text-070,
    BEGIN OF LINE,
      COMMENT 1(15) text-002 FOR FIELD p_bobot1 MODIF ID 001.
PARAMETERS: p_bobot1 LIKE bobot OBLIGATORY DEFAULT '25' MODIF ID 001.
SELECTION-SCREEN : COMMENT 23(4) text-003 FOR FIELD p_bobot1 MODIF ID 001,
END OF LINE,
BEGIN OF LINE,
COMMENT 1(15) text-004 FOR FIELD p_bobot2 MODIF ID 001.
PARAMETERS: p_bobot2 LIKE bobot OBLIGATORY DEFAULT '25' MODIF ID 001.
SELECTION-SCREEN : COMMENT 23(4) text-003 FOR FIELD p_bobot2 MODIF ID 001,
END OF LINE,
BEGIN OF LINE,
COMMENT 1(15) text-005 FOR FIELD p_bobot3 MODIF ID 001.
PARAMETERS: p_bobot3 LIKE bobot OBLIGATORY DEFAULT '35' MODIF ID 001.
SELECTION-SCREEN : COMMENT 23(4) text-003 FOR FIELD p_bobot3 MODIF ID 001,
END OF LINE,
BEGIN OF LINE,
COMMENT 1(15) text-006 FOR FIELD p_bobot4 MODIF ID 001.
PARAMETERS: p_bobot4 LIKE bobot OBLIGATORY DEFAULT '35' MODIF ID 001.
SELECTION-SCREEN : COMMENT 23(4) text-003 FOR FIELD p_bobot4 MODIF ID 001,
END OF LINE,
END OF BLOCK frm,
SKIP,
BEGIN OF BLOCK lb1 WITH FRAME TITLE text-080,
BEGIN OF LINE.
PARAMETERS onl RADIOBUTTON GROUP grp USER-COMMAND outbut.
SELECTION-SCREEN : COMMENT 3(35) text-007 FOR FIELD onl,
END OF LINE,
BEGIN OF LINE.
PARAMETERS upl  RADIOBUTTON GROUP grp.
SELECTION-SCREEN : COMMENT 3(35) text-008 FOR FIELD upl,
END OF LINE,

BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 3(5) text-010 FOR FIELD p_ptt.
PARAMETERS p_ptt RADIOBUTTON GROUP grp2 MODIF ID ptt.
SELECTION-SCREEN : COMMENT 15(5) text-011 FOR FIELD p_tdn.
PARAMETERS p_tdn RADIOBUTTON GROUP grp2 MODIF ID ptt.
SELECTION-SCREEN :
END OF LINE,

BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 3(20) text-009.
PARAMETERS p_filenm LIKE rlgrap-filename MODIF ID upl.
SELECTION-SCREEN :
END OF LINE,
END OF BLOCK lb1.
PARAMETERS p_avr AS CHECKBOX MODIF ID 001.
PARAMETERS p_delete AS CHECKBOX MODIF ID 001.

INCLUDE zghmmsd_block_stockcl1.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  REFRESH: i_vkbur.
  CLEAR: i_vkbur.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON p_date.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  IF upl IS NOT INITIAL.
    PERFORM f_modify_screen USING : '001' '0' ''.
  ELSE.
    PERFORM f_modify_screen USING : 'PTT' '0' ''.
  ENDIF.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen.
    WHEN space.
      PERFORM f_validate_screen.
  ENDCASE.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_filenm.
  PERFORM f_f4_value_on_request CHANGING p_filenm.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  IF upl IS NOT INITIAL.
    PERFORM f_get_upload_file.

    IF gv_message IS NOT INITIAL.
      MESSAGE gv_message TYPE 'S' DISPLAY LIKE 'E'.
      STOP.
    ENDIF.

    PERFORM f_get_existing_s940.

    IF gv_subrc IS INITIAL.
      PERFORM f_get_ending_stock_material.
      PERFORM f_outstanding_stock_akhir.
      PERFORM f_modify_s940.

      IF gt_out[] IS INITIAL.
        MESSAGE e000(zab) WITH 'No Data '.
        EXIT.
      ELSE.
        PERFORM f_alv TABLES gt_out.
      ENDIF.

    ELSE.
      MESSAGE i000(zab) WITH 'Please create Planning Hierarchy first,'
                             'contact Support Center TDS'.
    ENDIF.
  ELSE.
    IF p_date IS INITIAL.
      p_date = sy-datum.
    ENDIF.
    v_konob = 'PER_MAT'.
    v_spmon = p_date.
    CLEAR: r_spmon.
    FREE: r_spmon.
    r_spmon-low = v_spmon.
    r_spmon-high = v_spmon.

    IF v_spmon+4(2) = 1.
      r_spmon-high+4(2) = '12'.
      r_spmon-high(4)   = r_spmon-high(4) - 1.
      r_spmon-low+4(2) = r_spmon-low+4(2) + 9.
      r_spmon-low(4)   = r_spmon-low(4) - 1.

    ELSEIF v_spmon+4(2) <= 3.
      r_spmon-high+4(2) = r_spmon-high+4(2) - 1.
      r_spmon-low+4(2) = r_spmon-low+4(2) + 9.
      r_spmon-low(4)   = r_spmon-low(4) - 1.
    ELSE.
      r_spmon-high+4(2) = r_spmon-high+4(2) - 1.
      r_spmon-low+4(2) = r_spmon-low+4(2) - 3.

    ENDIF.
    r_spmon-sign = 'I'.
    r_spmon-option = 'BT'.
    APPEND r_spmon.

    SELECT vkbur FROM tvbur INTO TABLE i_vkbur
    WHERE vkbur IN s_werks.

    wa_s940-vrsio = vrsio.
    wa_s940-basme = 'ZPA'.
    wa_s940-konob = 'PER_MAT'.
    wa_s940-vkorg = p_vkorg.
    wa_s940-vtweg = p_vtweg.

    wa_s940-matnr = '##################'.
    wa_s940-vkbur = '####'.
    wa_s940-kvgr5 = '###'.
    wa_s940-spmon = v_spmon.

    wa_s940-kcqty = 999999999.
    wa_s940-aemenge = 0.
    MODIFY s940 FROM wa_s940.

    REFRESH: i_s940.
    CLEAR: i_s940.

    LOOP AT i_vkbur INTO wa_vkbur.
      PERFORM f_init_data.
      PERFORM f_get_data.
      PERFORM f_free_memory.
      CLEAR: wa_vkbur.
    ENDLOOP.

    IF i_s940[] IS INITIAL.
      WRITE: / 'No Data '.
      EXIT.
    ELSE.
      PERFORM f_alv TABLES i_s940.
      LOOP AT i_s940 INTO wa_s940.
        MODIFY s940 FROM wa_s940.
      ENDLOOP.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zghmmsd_block_stockf01.
*------------------common includes for the program---------------------*
