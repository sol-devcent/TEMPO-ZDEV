*&---------------------------------------------------------------------*
*& Program Name     : xxxxxxxxxxx                                      *
*& Module Name      : FI,CO,MM,SD,PM,QM,PP                             *
*& Author           : Budi.P                                           *
*& Functional       :                                                  *
*& Create Date      : 20/03/2013                                       *
*& Program Type     : Report/Enhancement                               *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : Upload taget sales for incentive                 *
*&                    xxxx xx xxxxxxx xxxx xx xx xx xxxxxxxxx          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zssut_e009 NO STANDARD PAGE HEADING
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

* ALV common functions
INCLUDE zabp_alv_common.

*------------------standard common includes---ends---------------------*


*------------------common TOP includes for the program----------------*
INCLUDE zssut_e009top.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS: pa_vkorg LIKE zssutdt022-vkorg OBLIGATORY MODIF ID vko,
            pa_vtweg LIKE zssutdt022-vtweg OBLIGATORY DEFAULT '10',
            pa_spart LIKE zssutdt022-spart OBLIGATORY DEFAULT '00',
            pa_vkbur LIKE zssutdt022-vkbur OBLIGATORY.
SELECTION-SCREEN SKIP.
PARAMETERS: work_di1 LIKE rlgrap-filename DEFAULT '*.csv'.
SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK ketr WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(75) text-021.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(75) text-023.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(75) text-024.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK ketr.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF SCREEN 500.
PARAMETERS: pa_col TYPE i DEFAULT 1,
            pa_row TYPE i DEFAULT 3.
SELECTION-SCREEN END OF SCREEN 500.
*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_init_vkorg.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON pa_vkorg.
  SELECT SINGLE vkorg INTO pa_vkorg FROM tvko
         WHERE vkorg = pa_vkorg.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH 'Company Code' pa_vkorg 'Not Found'.
  ENDIF.

AT SELECTION-SCREEN ON pa_vkbur.
  AUTHORITY-CHECK OBJECT 'V_VBKA_VKO'
           ID 'VKBUR' FIELD pa_vkbur.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH
      'You have no authorization for Sl.Off ' pa_vkbur.
  ENDIF.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR work_di1.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = sy-cprog
      dynpro_number = '1000'
    IMPORTING
      file_name     = work_di1.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data USING gd_extension.
  PERFORM f_process_data.
  PERFORM f_check_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zssut_e009f01.

*------------------common includes for the program---------------------*
