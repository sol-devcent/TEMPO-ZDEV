REPORT ztdnfi_i003  NO STANDARD PAGE HEADING
                        LINE-SIZE  184
                        LINE-COUNT 65(4).

INCLUDE zghfi_r001_top.

INCLUDE zabp_header.
INCLUDE zabp_alv_common.


DATA: gv_variant TYPE disvariant.

SELECTION-SCREEN BEGIN OF BLOCK general_block WITH FRAME TITLE TEXT-001.
PARAMETERS p_vkorg TYPE zghfidt001-vkorg DEFAULT '8020' OBLIGATORY.
SELECT-OPTIONS: s_vkbur FOR zghfidt001-vkbur OBLIGATORY NO INTERVALS,
  s_vbeln FOR zghfidt001-vbeln,
  s_kunnr FOR zghfidt001-kunnr,
  s_erdat FOR zghfidt001-erdat OBLIGATORY.
SELECTION-SCREEN END OF BLOCK general_block.

SELECTION-SCREEN BEGIN OF BLOCK layout_block WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_layout TYPE disvariant-variant.
SELECTION-SCREEN END OF BLOCK layout_block.


INITIALIZATION.
* Clear or reset s_erdat select-options variable
CLEAR: s_erdat[].
* Join the current year and month with 01 which is the first day of the month and assign in erdat-low
CONCATENATE SY-DATUM(6) '01' INTO s_erdat-low.
s_erdat-high = SY-DATUM. " Assign current date in erdat-high
APPEND s_erdat. " Append a new row to the internal table



*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layout.
*  The report name the layout belongs to
  gv_variant-report = sy-repid.
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
  EXPORTING
    is_variant = gv_variant
    i_save = 'A'
  IMPORTING
    es_variant = gv_variant
  EXCEPTIONS
    others = 1.
  IF sy-subrc = 0.
    p_layout = gv_variant-variant.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.

AT SELECTION-SCREEN ON p_vkorg.
  AUTHORITY-CHECK OBJECT 'V_VBRK_VKO'
           ID 'VKORG' FIELD p_vkorg
           ID 'ACTVT' FIELD '03'.
  IF sy-subrc <> 0.
    MESSAGE 'No Authorization' TYPE 'E'.
  ENDIF.


***********************************************************************
*s t a r t - o f - s e l e c t i o n                             *
***********************************************************************
START-OF-SELECTION.

  PERFORM f_get_data.
  PERFORM f_print_data.
  INCLUDE zghfi_r001_f01.

*required field
*1.	VKORG ( menggunakan parameter ) - Wajib
*2.	VKBUR ( menggunakan select option ) - Wajib
*3.	VBELN ( menggunakan select option ) - Optional
*4.	KUNNR  ( menggunakan select option ) – Optional
*5.	ERDAT ( menggunakan select option ) – wajib
*  Default awal bulan - hr ini
*  double click Billing No. vf03

* COLUMN bisa dihide atau tampil
* Semua ditampil kecuali year
