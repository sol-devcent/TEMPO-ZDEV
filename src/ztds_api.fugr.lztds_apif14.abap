*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF14.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_TIMDES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_timdes_data  CHANGING p_zproses
                          p_event
                          p_zdata
                          p_status
                          p_message.

  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  DATA: lv_message(150).
  DATA: lv_webno   TYPE zfidt010-webno.
  DATA: lv_subrc TYPE sy-subrc.
  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'TIMDES'.
  ls_ztdsitdt006-zevent = p_event.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.
  p_status = 'S'.
  DATA: lt_listobject TYPE TABLE OF abaplist,
        lt_ascii      TYPE TABLE OF soli. " Rekomendasi utama

  CASE p_event.
    WHEN 'TIMDES_PAYMENT'.
      lv_webno = p_zdata.
      SUBMIT ztimdesfi_i001 WITH pa_webno = lv_webno
                            WITH radio1 = 'X'
                            WITH radio2 = ' '
                            EXPORTING LIST TO MEMORY  AND RETURN.

      CALL FUNCTION 'LIST_FROM_MEMORY'
        TABLES
          listobject = lt_listobject
        EXCEPTIONS
          not_found  = 1
          OTHERS     = 2.

      IF sy-subrc = 0.
        " 3. Konversi objek list menjadi teks biasa (ASCII)
        CALL FUNCTION 'LIST_TO_ASCI'
          TABLES
            listobject         = lt_listobject
            listasci           = lt_ascii " Variabel lt_ascii otomatis menyesuaikan dengan tipe SOLI
          EXCEPTIONS
            empty_list         = 1
            list_index_invalid = 2
            OTHERS             = 3.

        " lt_ascii sekarang berisi data teks baris demi baris dari report
      ENDIF.
      IF lt_ascii[] IS NOT INITIAL.
        LOOP AT lt_ascii ASSIGNING FIELD-SYMBOL(<fs>).
          IF <fs> IS ASSIGNED.
            lv_message = <fs>-line.
          ENDIF.
        ENDLOOP.
      ENDIF.
    WHEN 'TIMDES_CLEARING'.
      lv_webno = p_zdata.
      SUBMIT ztimdesfi_i001 WITH pa_webno = lv_webno
                            WITH radio1 = ' '
                            WITH radio2 = 'X'
                            EXPORTING LIST TO MEMORY  AND RETURN.
      CALL FUNCTION 'LIST_FROM_MEMORY'
        TABLES
          listobject = lt_listobject
        EXCEPTIONS
          not_found  = 1
          OTHERS     = 2.

      IF sy-subrc = 0.
        " 3. Konversi objek list menjadi teks biasa (ASCII)
        CALL FUNCTION 'LIST_TO_ASCI'
          TABLES
            listobject         = lt_listobject
            listasci           = lt_ascii " Variabel lt_ascii otomatis menyesuaikan dengan tipe SOLI
          EXCEPTIONS
            empty_list         = 1
            list_index_invalid = 2
            OTHERS             = 3.

        " lt_ascii sekarang berisi data teks baris demi baris dari report
      ENDIF.
      IF lt_ascii[] IS NOT INITIAL.
        LOOP AT lt_ascii ASSIGNING <fs>.
          IF <fs> IS ASSIGNED.
            lv_message = <fs>-line.
          ENDIF.
        ENDLOOP.
      ENDIF.
    WHEN OTHERS.
      CONCATENATE 'Err: ' p_event ' not found' INTO lv_message.
      p_status = 'E'.
  ENDCASE.
  p_message = lv_message.
  ls_ztdsitdt006-status = p_status.
  ls_ztdsitdt006-message = lv_message.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.

ENDFORM.
