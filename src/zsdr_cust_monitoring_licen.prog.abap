*&---------------------------------------------------------------------*
*& Program Name     : ZSDR_CUST_MONITORING_LICEN                       *
*& Author           : Budi                                             *
*& Functional       :                                                  *
*& Create Date      : 26.08.2021                                       *
*& Program Type     : Report                                           *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : Customer Monitoring License Report               *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zsdr_cust_monitoring_licen NO STANDARD PAGE HEADING
                                  LINE-SIZE 255.

*------------------common TOP includes for the program----------------*
INCLUDE zsdr_cust_monitoring_licentop.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETER     : p_vkorg LIKE knvv-vkorg OBLIGATORY.
SELECT-OPTIONS: s_vkbur FOR knvv-vkbur,
                s_kdgrp FOR knvv-kdgrp,
                s_kvgr3 FOR knvv-kvgr3,
                s_vkgrp FOR knvv-vkgrp,
                s_kunnr FOR knvv-kunnr,
                s_abtnr FOR knvk-abtnr.
SELECTION-SCREEN END OF BLOCK data.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zsdr_cust_monitoring_licenf01.

*------------------common includes for the program---------------------*
