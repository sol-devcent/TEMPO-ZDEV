*&---------------------------------------------------------------------*
*& Report  ZS_CLOSING_PAKET_BACKGROUND
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zs_closing_paket_background NO STANDARD PAGE HEADING.

*------------------common TOP includes for the program----------------*
INCLUDE zs_closing_paket_backgroundtop.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS: p_paket LIKE zsparameter-paket OBLIGATORY,
            p_spmon LIKE s705-spmon DEFAULT sy-datum(6) OBLIGATORY,
            p_vkorg LIKE tvko-vkorg DEFAULT '8020' OBLIGATORY,
            p_vtweg LIKE zscust_opp-vtweg DEFAULT '10' OBLIGATORY.
SELECT-OPTIONS: s_vkbur FOR s705-vkbur OBLIGATORY,
                s_kunnr FOR s705-pkunwe.
PARAMETERS: p_exec  LIKE btch1140-execserver DEFAULT 'tstprd02_P01_80'
                                             OBLIGATORY.
SELECTION-SCREEN SKIP.
PARAMETERS: pa_datum  LIKE tbtcjob-sdlstrtdt DEFAULT sy-datum MODIF ID sdt,
            pa_uzeit  LIKE tbtcjob-sdlstrttm DEFAULT sy-uzeit MODIF ID stm,
            pa_time   TYPE i DEFAULT 300 OBLIGATORY,
            p_var     TYPE btceventid.

SELECTION-SCREEN SKIP 1.
PARAMETERS: p_updvk AS CHECKBOX DEFAULT 'X' MODIF ID pe3.
PARAMETERS: p_pexwb AS CHECKBOX MODIF ID pe3.


SELECTION-SCREEN END OF BLOCK block1.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_init_sloff.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zs_closing_paket_backgrounf01.
