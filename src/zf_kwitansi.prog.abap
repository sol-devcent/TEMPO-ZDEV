*&---------------------------------------------------------------------*
*& Program Name     : xxxxxxxxxxx                                      *
*& Module Name      : FI,CO,MM,SD,PM,QM,PP                             *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : dd/mm/yyyy                                       *
*& Program Type     : Report/Enhancement                               *
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
REPORT zf_kwitansi NO STANDARD PAGE HEADING
                   LINE-SIZE 255.
*              ZFU.                 "Message class for Finish Unit
*              ZSP.                 "Spare Parts
*              ZPE.                 "Production and Engineering
*              ZFA.                 "Finance
*              ZAB.                 "ABAP and Tools

*------------------standard common includes----------------------------*
* Authorization checking macros
INCLUDE zabp_atz.

* Upload and download flat file macors
INCLUDE zabp_udf.

* common report header and other functions
INCLUDE zabp_header.

* other common functions
INCLUDE zabp_frm.

* ALV common functions
INCLUDE zabp_alv_common.

* BDC Include
INCLUDE zabp_bdc.
*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zf_kwitansitop.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_ztran      TYPE ztran MODIF ID ztr.
PARAMETERS pa_bukrs      LIKE bsid-bukrs MODIF ID buk.
PARAMETERS pa_vkbur      LIKE knvv-vkbur MODIF ID vkb.
SELECT-OPTIONS so_vkbur  FOR knvv-vkbur MODIF ID svk.
SELECT-OPTIONS so_kunnr  FOR bsid-kunnr MODIF ID kun.
SELECT-OPTIONS so_zuonr  FOR bsid-zuonr MODIF ID zuo.
PARAMETERS pa_gstid      LIKE bapi3008-key_date MODIF ID gst
                         DEFAULT sy-datum OBLIGATORY.
SELECT-OPTIONS so_bldat  FOR bsid-budat MODIF ID bld
                         DEFAULT sy-datum OBLIGATORY.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF SCREEN 1100 AS WINDOW.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio4 RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND rad.
SELECTION-SCREEN COMMENT 3(40) pa_name1 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 3(40) pa_name2 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio6 RADIOBUTTON GROUP grp1.
PARAMETERS pa_namec  LIKE adrc-name1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK signature WITH FRAME TITLE text-004.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS pa_name3  LIKE zfstkwi-petugas1 MODIF ID sig.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK signature.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 45(35) text-005 MODIF ID msg.
SELECTION-SCREEN END OF LINE.
PARAMETERS pa_ttfdt   TYPE sy-datum MODIF ID ttf
                      DEFAULT sy-datum OBLIGATORY.
SELECTION-SCREEN END OF SCREEN 1100.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP rad USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP rad.
PARAMETERS radio3 RADIOBUTTON GROUP rad.
PARAMETERS radio7 RADIOBUTTON GROUP rad MODIF ID bom.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio8 RADIOBUTTON GROUP rad MODIF ID bom.
SELECTION-SCREEN COMMENT 3(44) text-006 FOR FIELD radio8.
SELECTION-SCREEN END OF LINE.
PARAMETERS radio9 RADIOBUTTON GROUP rad.
PARAMETERS radio10 RADIOBUTTON GROUP rad.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio11 RADIOBUTTON GROUP rad.
SELECTION-SCREEN COMMENT 3(44) text-007 FOR FIELD radio11.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK reprint WITH FRAME TITLE text-003.
PARAMETERS pa_check AS CHECKBOX MODIF ID chk.
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS so_nokwi FOR zfkwi-nokwi MODIF ID nok.
SELECT-OPTIONS so_nottf FOR zfkwi-nottf MODIF ID not.
SELECTION-SCREEN END OF BLOCK reprint.
SELECTION-SCREEN END OF BLOCK option.
*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI' OR space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CASE 'X'.
    WHEN radio7.
      PERFORM f_get_delete_data.
      PERFORM f_print_data.

    WHEN radio8.
*Read all the lock details in system
      PERFORM f_cek_lock.

      CLEAR i_bdc.
      PERFORM f_dynpro USING:
         'X'  'SAPMSVMA'                '0100',
         ' '  'BDC_OKCODE'              '=UPD',
         ' '  'VIEWNAME'                'ZFKWIOUT',
         ' '  'VIMDYNFLDS-LTD_DTA_NO'   ' ',
         ' '  'VIMDYNFLDS-LTD_DTA_AR'   'X',

         'X'  'SAPLSVIX'                '0210',
         ' '  'MARK_CHECKBOX(01)'       'X',
         ' '  'MARK_CHECKBOX(02)'       'X',

         'X'  'SAPLSVIX'                '0100',
         ' '  'BDC_OKCODE'              '=OKAY',
         ' '  'D0100_FIELD_TAB-LOWER_LIMIT(01)' pa_bukrs,
         ' '  'D0100_FIELD_TAB-LOWER_LIMIT(02)' pa_vkbur.

      CALL TRANSACTION 'YF01' USING i_bdc
                              MODE 'E'
                              UPDATE 'S'
                              MESSAGES INTO i_messtab.

      CALL FUNCTION 'DEQUEUE_EZFKWIOUT'
        EXPORTING
          bukrs          = pa_bukrs
          vkbur          = pa_vkbur
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.

    WHEN radio9.
      PERFORM f_get_data.
      PERFORM f_print_data.

    WHEN radio10.
      PERFORM f_init_data CHANGING gv_error.
      PERFORM f_lead_time.
      PERFORM f_print_data.

    WHEN radio11.
      PERFORM f_get_data_radio11.
      PERFORM f_print_data.

    WHEN OTHERS.
      PERFORM f_init_data CHANGING gv_error.
      IF gv_error IS INITIAL.
        PERFORM f_get_data.
        PERFORM f_process_data.
        PERFORM f_print_data.
        PERFORM f_free_memory.
      ELSE.
        CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
          EXPORTING
            popup_title  = 'Error message'
            message_text = 'No data found'.
      ENDIF.
  ENDCASE.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zf_kwitansif01.

*------------------common includes for the program---------------------*
