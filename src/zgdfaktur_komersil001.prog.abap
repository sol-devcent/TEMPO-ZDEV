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
REPORT zgdfaktur_komersil001 NO STANDARD PAGE HEADING
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
INCLUDE zgdfaktur_komersil001top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS:
  pa_vkorg LIKE vbrk-vkorg OBLIGATORY.
SELECT-OPTIONS:
  so_vbeln FOR vbrk-vbeln,
  so_xblnr FOR vbrk-xblnr,
  so_fkdat FOR vbrk-fkdat MODIF ID fkd.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1
             USER-COMMAND dik DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(35) text-003 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(35) text-004 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK data1.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  DATA: ld_low   LIKE sy-datum,
        ld_high  LIKE sy-datum.

  RANGES: lr_fkdat FOR sy-datum.

  IF so_fkdat-low IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'FKD'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH 'Make an entry in all required fields'.
  ELSE.
    CONCATENATE so_fkdat-low(6) '01' INTO ld_low.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = ld_low
      IMPORTING
        last_day_of_month = ld_high.

    lr_fkdat-low    = ld_low.
    lr_fkdat-high   = ld_high.
    lr_fkdat-sign   = 'E'.
    lr_fkdat-option = 'BT'.
    APPEND lr_fkdat.

    IF so_fkdat-high IS INITIAL.
      ld_low = so_fkdat-low.
      CLEAR: so_fkdat.
      FREE: so_fkdat.
      so_fkdat-low    = ld_low.
      so_fkdat-high   = ld_high.
      so_fkdat-sign   = 'I'.
      so_fkdat-option = 'BT'.
      APPEND so_fkdat.
    ELSE.
      IF so_fkdat-low IN lr_fkdat OR
        so_fkdat-high IN lr_fkdat.
        MESSAGE e000(zab) WITH 'Invalid period selected'.
      ENDIF.
    ENDIF.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'V_VBRK_VKO'
           ID 'ACTVT' FIELD '03'
           ID 'VKORG' FIELD pa_vkorg.
  IF sy-subrc = 4.
    MESSAGE e000(zab) WITH 'No authorization for Sales Organization'
                            pa_vkorg.
  ELSEIF sy-subrc <> 0.
    MESSAGE e000(zab) WITH 'Internal problem in authorization check'.
  ENDIF.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  CASE sy-tcode.
    WHEN 'ZGDSDR0005' OR 'SE38' OR 'SA38'.
      PERFORM f_print_data.
    WHEN OTHERS.
      PERFORM f_save_table.
  ENDCASE.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.


*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdfaktur_komersil001f01.

*------------------common includes for the program---------------------*
