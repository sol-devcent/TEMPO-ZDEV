*----------------------------------------------------------------------*
***INCLUDE LZTDN_APIF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_JSON_AWB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_STR  text
*      <--P_GT_AWBIMAGE  text
*----------------------------------------------------------------------*
FORM f_convert_json_awb  USING p_str TYPE string
                         CHANGING p_awbimage TYPE ty_awbimage..

  DATA : ls_awbimage TYPE ty_awbimage.
  DATA:   lv_json_data     TYPE string. ",

  lv_json_data = p_str.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_awbimage ).
  p_awbimage = ls_awbimage.

ENDFORM.                    " F_CONVERT_JSON_AWB
*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TO_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_AWBIMAGE  text
*----------------------------------------------------------------------*
FORM f_save_to_table  USING p_awbimage TYPE ty_awbimage.
  DATA : ls_awbimage TYPE ty_awbimage.
  DATA: lt_awb_image TYPE STANDARD TABLE OF ty_data.
  DATA: ls_awb_image TYPE ty_data.
  DATA: ls_url_awb TYPE ty_url.
  DATA: ls_ztdnsddt022 TYPE ztdnsddt022.
  DATA: lt_ztdnsddt022 TYPE STANDARD TABLE OF ztdnsddt022.
  DATA: ls_ztdnsddt022d TYPE ztdnsddt022d.
  DATA: lt_ztdnsddt022d TYPE STANDARD TABLE OF ztdnsddt022d.
  DATA: lv_url TYPE text1024.
  DATA: lt_vbkd TYPE STANDARD TABLE OF vbkd,
        ls_vbkd TYPE vbkd.
  DATA : let_docflow           TYPE tdt_docflow.
  DATA: lw_docflow           TYPE tds_docflow. " OCCURS 0 WITH HEADER LINE.
  DATA: lv_ctr TYPE i.
  DATA: lv_nourut LIKE ztdnsddt022d-nourut.
  DATA: p_return(1).
  DATA: lv_message TYPE char250_d.
  ls_awbimage = p_awbimage.
  IF ls_awbimage-awb_image[] IS NOT INITIAL.
    CLEAR: lv_ctr,  lv_nourut.
    LOOP AT ls_awbimage-awb_image INTO ls_awb_image.
      ADD 1 TO lv_ctr.
      ls_ztdnsddt022-bstkd  = ls_awb_image-no_order.
      ls_ztdnsddt022-kode_mp  = ls_awb_image-kode_mp.
      ls_ztdnsddt022-kode_shop  = ls_awb_image-kode_shop.
      ls_ztdnsddt022-znotrans	= ls_awb_image-no_transaksi.
      ls_ztdnsddt022-vbeln  = ls_awb_image-no_dn.
      ls_ztdnsddt022-zpage = ls_awb_image-count_page.
      ls_ztdnsddt022-no_awb	= ls_awb_image-no_awb.
      ls_ztdnsddt022-erdat  = sy-datum.
      ls_ztdnsddt022-erzet  = sy-uzeit.
      ls_ztdnsddt022-ernam  = sy-uname.
      "ls_ZTDNSDDT022-ZMESSAGE  ZMESSAGE
      ls_ztdnsddt022-status	= ls_awb_image-status.
      CLEAR: lv_nourut.
      LOOP AT ls_awb_image-url_awb INTO ls_url_awb.
        MOVE-CORRESPONDING ls_ztdnsddt022 TO ls_ztdnsddt022d.
        ADD 1 TO lv_nourut.
        lv_url = ls_url_awb-url_awb.
        ls_ztdnsddt022d-zurl = ls_url_awb-url_awb.
        ls_ztdnsddt022d-no_awb = ls_url_awb-namafile.
        ls_ztdnsddt022d-nourut = lv_nourut.
        CLEAR: p_return.
        PERFORM proses_file USING 'A' ' ' ls_url_awb-namafile  lv_url ' ' CHANGING p_return lv_message.
        gv_message = lv_message.
        gv_noawb = ls_url_awb-namafile.
        gv_status = p_return.
        IF p_return IS NOT INITIAL.
          ls_ztdnsddt022d-status = 'E'.
          ls_ztdnsddt022-zmessage = 'Image tidak ditemukan atau corrupt'.
          ls_ztdnsddt022-status = 'E'.
        ENDIF.
        APPEND ls_ztdnsddt022d TO lt_ztdnsddt022d.
        MODIFY ztdnsddt022d FROM ls_ztdnsddt022d.
        CLEAR: ls_ztdnsddt022d.
      ENDLOOP.
      APPEND ls_ztdnsddt022 TO gt_ztdnsddt022.
      CLEAR: ls_ztdnsddt022.
    ENDLOOP.
    IF gt_ztdnsddt022[] IS NOT INITIAL.
      SORT gt_ztdnsddt022 BY bstkd kode_mp kode_shop.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_ztdnsddt022 FROM ztdnsddt022
        FOR ALL ENTRIES IN gt_ztdnsddt022
        WHERE bstkd = gt_ztdnsddt022-bstkd
          AND kode_mp = gt_ztdnsddt022-kode_mp
          AND kode_shop = gt_ztdnsddt022-kode_shop. " ORDER BY bstkd kode_mp kode_shop.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_vbkd FROM vbkd
        FOR ALL ENTRIES IN gt_ztdnsddt022
        WHERE bstkd_m = gt_ztdnsddt022-bstkd.
    ENDIF.
    LOOP AT gt_ztdnsddt022 INTO gs_ztdnsddt022.
      SORT lt_ztdnsddt022 BY bstkd kode_mp kode_shop.
      READ TABLE lt_ztdnsddt022 INTO ls_ztdnsddt022
      WITH KEY bstkd = gs_ztdnsddt022-bstkd
               kode_mp = gs_ztdnsddt022-kode_mp
               kode_shop = gs_ztdnsddt022-kode_shop
               BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_ztdnsddt022-status = 'D'.
        MODIFY ztdnsddt022 FROM ls_ztdnsddt022.
      ENDIF.
      SORT lt_vbkd BY bstkd_m.
      READ TABLE lt_vbkd INTO ls_vbkd
      WITH KEY bstkd_m = gs_ztdnsddt022-bstkd
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'SD_DOCUMENT_FLOW_GET'
          EXPORTING
            iv_docnum  = ls_vbkd-vbeln
          IMPORTING
            et_docflow = let_docflow.
        DELETE let_docflow[] WHERE posnv NE '000000'.
        LOOP AT let_docflow INTO lw_docflow WHERE vbtyp_n = 'J'.
          gs_ztdnsddt022-vbeln = lw_docflow-vbeln.
        ENDLOOP.
      ENDIF.
      MODIFY ztdnsddt022 FROM gs_ztdnsddt022.
    ENDLOOP.
  ENDIF.
  CLEAR: gt_ztdnsddt022[], gt_ztdnsddt022, gs_ztdnsddt022.

ENDFORM.                    " F_SAVE_TO_TABLE
*&---------------------------------------------------------------------*
*&      Form  PROSES_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0202   text
*      -->P_0203   text
*      -->P_LS_URL_AWB_NAMAFILE  text
*      -->P_LV_URL  text
*      -->P_0206   text
*      <--P_P_RETURN  text
*----------------------------------------------------------------------*
FORM proses_file  USING p_type p_dirname p_filename p_url TYPE text1024 zpage CHANGING p_return p_message TYPE char250_d.
  DATA: BEGIN OF lt_bitmap OCCURS 0,
          l(64) TYPE x,
        END OF lt_bitmap.
  DATA: lv_fullfile LIKE edi_path-pthnam.

  DATA  wa_stxbitmaps TYPE stxbitmaps.
  DATA : lv_resolution     TYPE stxbitmaps-resolution,
         lv_format(3),
         lv_name            TYPE stxbitmaps-tdname,
         lv_object          TYPE stxbitmaps-tdobject,
         lv_id              TYPE stxbitmaps-tdid,
         lv_btype           TYPE stxbitmaps-tdbtype,
         lv_docid           TYPE stxbitmaps-docid,
         lv_resident        TYPE stxbitmaps-resident,
         lv_title           LIKE bapisignat-prop_value,
         lv_ext(5),
         lv_totbytecount       TYPE i,
         lv_bytecount       TYPE i,

         lv_width_tw        TYPE stxbitmaps-widthtw,
         lv_height_tw       TYPE stxbitmaps-heighttw,
         lv_width_pix       TYPE  stxbitmaps-widthpix,
         lv_height_pix      TYPE  stxbitmaps-heightpix,
         lv_bds_bytecount   TYPE  i,
        lv_bds_object      TYPE REF TO cl_bds_document_set,
        lv_bds_content     TYPE sbdst_content,
        lv_bds_components  TYPE sbdst_components,
        wa_bds_components TYPE LINE OF sbdst_components,
        lv_bds_signature   TYPE sbdst_signature,
        wa_bds_signature  TYPE LINE OF sbdst_signature,
        lv_bds_properties  TYPE sbdst_properties,
        wa_bds_properties TYPE LINE OF sbdst_properties,
         lv_object_key      TYPE sbdst_object_key,
         l_tab             TYPE ddobjname.
  DATA: lv_status_code(10), "   TYPE C ,
        lv_status_text(100), "   TYPE C ,
        lv_response_entity_body_length   TYPE i ,
        lv_request_entity_body_length TYPE i. "(80). " = 'Check type of data required'.

  DATA: BEGIN OF lt_request_body OCCURS 0,
            line(3000),
       END OF  lt_request_body.

  DATA: BEGIN OF lt_response_body OCCURS 0,
            line(1500),
         END OF  lt_response_body.
  DATA: BEGIN OF lt_response_header  OCCURS 0,
           line(1500),
         END OF  lt_response_header.
  DATA: BEGIN OF lt_request_header   OCCURS 0,
           line(1500),
         END OF  lt_request_header.

  lv_object = 'GRAPHICS'.
  lv_id = 'BMAP'.
  lv_btype = 'BMON'.
  lv_format = 'BMP'.
  SPLIT p_filename AT '.' INTO lv_name lv_ext.
  TRANSLATE lv_name TO UPPER CASE.

  DATA l_text(100).

  CALL FUNCTION 'SAPSCRIPT_DELETE_GRAPHIC_BDS'
    EXPORTING
      i_object      = lv_object
      i_name        = lv_name
      i_id          = lv_id
      i_btype       = lv_btype
      dialog        = ' '
    EXCEPTIONS
      delete_failed = 1
      not_found     = 2
      canceled      = 3
      OTHERS        = 4.
  IF sy-subrc = 0.
    l_text = text-m01.
    REPLACE '&' WITH lv_name INTO l_text.
    CONDENSE l_text.
    MESSAGE s252(td) WITH l_text.
    PERFORM write_message CHANGING p_message.
"    CONCATENATE 'Message : ' p_message INTO p_message.
  ELSE.
    CASE sy-subrc.
      WHEN 1.
        MESSAGE s286(td) WITH lv_name.
      WHEN 2.
        MESSAGE s287(td) WITH lv_name.
      WHEN 3.
        MESSAGE s178(td).
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDCASE.
    PERFORM write_message CHANGING p_message.
"    CONCATENATE 'Message : ' p_message INTO p_message.
  ENDIF.
  PERFORM enqueue_graphic IN PROGRAM saplstxbitmaps USING lv_object "'GRAPHICS'
                                   lv_name
                                   lv_id
                                   lv_btype.
  CLEAR: lv_totbytecount, lt_bitmap.
  IF p_type = 'F'.
  ELSE.
    lv_request_entity_body_length = 64.
    CALL FUNCTION 'HTTP_GET'
      EXPORTING
        absolute_uri                = p_url "ld_absolute_uri
        request_entity_body_length  = lv_request_entity_body_length
        rfc_destination             = ' ' "'SAPHTTPA' "p_rfc
"        blankstocrlf                = 'Y'
      IMPORTING
        status_code                 = lv_status_code    "timeout = '0'
        status_text                 = lv_status_text
        response_entity_body_length = lv_bds_bytecount "lv_response_entity_body_length
      TABLES
        request_entity_body         = lt_request_body
        response_entity_body        = lt_bitmap "lt_response_body
        response_headers            = lt_response_header
        request_headers             = lt_request_header.
  ENDIF.

  IF lt_bitmap[] IS NOT INITIAL.
    CALL FUNCTION 'SAPSCRIPT_CONVERT_BITMAP_BDS'
      EXPORTING
        color                    = 'X' "l_color "space
        format                   = lv_format " 'BMP' "'TIF' " p_format "BMP
        resident                 = '' " p_resident "space
        bitmap_bytecount         = lv_totbytecount "l_bytecount "167138
        compress_bitmap          = 'X' "p_bmcomp
      IMPORTING
        width_tw                 = lv_width_tw
        height_tw                = lv_height_tw
        width_pix                = lv_width_pix
        height_pix               = lv_height_pix
        dpi                      = lv_resolution
        bds_bytecount            = lv_bds_bytecount
      TABLES
        bitmap_file              = lt_bitmap
        bitmap_file_bds          = lv_bds_content
      EXCEPTIONS
        format_not_supported     = 1
        no_bmp_file              = 2
        bmperr_invalid_format    = 3
        bmperr_no_colortable     = 4
        bmperr_unsup_compression = 5
        bmperr_corrupt_rle_data  = 6
        OTHERS                   = 7.
    IF sy-subrc <> 0.
      lv_btype = lv_totbytecount.
      PERFORM dequeue_graphic IN PROGRAM saplstxbitmaps USING lv_object "'GRAPHICS'
                                    lv_name
                                    lv_id "'BMAP'
                                    lv_btype.
      PERFORM write_message CHANGING p_message.
      CONCATENATE 'Error : ' p_message INTO p_message.
      p_return = 4.
      RETURN.
    ENDIF.
* Save bitmap in BDS
    CREATE OBJECT lv_bds_object.
    wa_bds_components-doc_count  = '1'.
    wa_bds_components-comp_count = '1'.
    wa_bds_components-mimetype   = c_bds_mimetype.
    wa_bds_components-comp_size  = lv_bds_bytecount.
    APPEND wa_bds_components TO lv_bds_components.
*      IF p_docid IS INITIAL.          " graphic is new
    CLEAR lv_docid.
    wa_bds_signature-doc_count = '1'.
    APPEND wa_bds_signature TO lv_bds_signature.

    CALL METHOD lv_bds_object->create_with_table
      EXPORTING
        classname  = c_bds_classname
        classtype  = c_bds_classtype
        components = lv_bds_components
        content    = lv_bds_content
      CHANGING
        signature  = lv_bds_signature
        object_key = lv_object_key
      EXCEPTIONS
        OTHERS     = 1.
    IF sy-subrc <> 0.
      PERFORM dequeue_graphic IN PROGRAM saplstxbitmaps USING lv_object
                                    lv_name
                                    lv_id
                                    lv_btype.
      PERFORM write_message CHANGING p_message.
      CONCATENATE 'Error : ' p_message INTO p_message.
      p_return = 4.
      RETURN.
    ENDIF.
    READ TABLE lv_bds_signature INDEX 1 INTO wa_bds_signature
    TRANSPORTING doc_id.
    IF sy-subrc = 0.
      lv_docid = wa_bds_signature-doc_id.
    ELSE.
      PERFORM dequeue_graphic IN PROGRAM saplstxbitmaps USING lv_object
                                    lv_name
                                    lv_id
                                    lv_btype.
      PERFORM write_message CHANGING p_message.
      CONCATENATE 'Error : ' p_message INTO p_message.
      p_return = 4.
      RETURN.
*          MESSAGE e285 WITH p_name 'BDS'.
    ENDIF.
********* read object_key for faster access *****
    CLEAR lv_object_key.
    CLEAR wa_stxbitmaps.
    SELECT SINGLE * FROM stxbitmaps INTO wa_stxbitmaps
        WHERE tdobject = lv_object
          AND tdid     = lv_id
          AND tdname   = lv_name
          AND tdbtype  = lv_btype.
    SELECT SINGLE tabname FROM bds_locl INTO l_tab
       WHERE classname = c_bds_classname
          AND classtype = c_bds_classtype.
    IF sy-subrc = 0.
      SELECT SINGLE object_key FROM (l_tab) INTO lv_object_key
        WHERE loio_id = wa_stxbitmaps-docid+10(32)
          AND classname = c_bds_classname
            AND classtype = c_bds_classtype.
    ENDIF.
******** read object_key end ********************
    CALL METHOD lv_bds_object->update_with_table
      EXPORTING
        classname     = c_bds_classname
        classtype     = c_bds_classtype
        object_key    = lv_object_key
        doc_id        = lv_docid
        doc_ver_no    = '1'
        doc_var_id    = '1'
      CHANGING
        components    = lv_bds_components
        content       = lv_bds_content
      EXCEPTIONS
        nothing_found = 1
        OTHERS        = 2.
    IF sy-subrc = 1.   " inconsistency STXBITMAPS - BDS; repeat check in
      wa_bds_signature-doc_count = '1'.
      APPEND wa_bds_signature TO lv_bds_signature.
      CALL METHOD lv_bds_object->create_with_table
        EXPORTING
          classname  = c_bds_classname
          classtype  = c_bds_classtype
          components = lv_bds_components
          content    = lv_bds_content
        CHANGING
          signature  = lv_bds_signature
          object_key = lv_object_key
        EXCEPTIONS
          OTHERS     = 1.
      IF sy-subrc <> 0.
        PERFORM dequeue_graphic IN PROGRAM saplstxbitmaps USING lv_object
                                      lv_name
                                      lv_id
                                      lv_btype.
        PERFORM write_message CHANGING p_message.
        CONCATENATE 'Error : ' p_message INTO p_message.
        p_return = 4.
        RETURN.
      ENDIF.
      READ TABLE lv_bds_signature INDEX 1 INTO wa_bds_signature
      TRANSPORTING doc_id.
      IF sy-subrc = 0.
        lv_docid = wa_bds_signature-doc_id.
      ELSE.
        PERFORM dequeue_graphic IN PROGRAM saplstxbitmaps USING lv_object
                                      lv_name
                                      lv_id
                                      lv_btype.
        PERFORM write_message CHANGING p_message.
        CONCATENATE 'Error : ' p_message INTO p_message.
        p_return = 4.
        RETURN.
*            MESSAGE e285 WITH p_name 'BDS'.
      ENDIF.

    ELSEIF sy-subrc = 2.
      PERFORM dequeue_graphic IN PROGRAM saplstxbitmaps USING lv_object
                                    lv_name
                                    lv_id
                                    lv_btype.
      "MESSAGE e285 WITH lv_name 'BDS'.
      CONCATENATE 'Error: Graphic ' lv_name 'could not be saved (BDS)' INTO p_message.
      "      PERFORM write_message CHANGING p_message.
      p_return = 4.
      RETURN.
    ENDIF.

* Save bitmap header in STXBITPMAPS
    wa_stxbitmaps-tdname     = lv_name.
    wa_stxbitmaps-tdobject   = lv_object.
    wa_stxbitmaps-tdid       = lv_id.
    wa_stxbitmaps-tdbtype    = lv_btype.
    wa_stxbitmaps-docid      = lv_docid.
    wa_stxbitmaps-widthpix   = lv_width_pix.
    wa_stxbitmaps-heightpix  = lv_height_pix.
    wa_stxbitmaps-widthtw    = lv_width_tw.
    wa_stxbitmaps-heighttw   = lv_height_tw.
    wa_stxbitmaps-resolution = lv_resolution.
    wa_stxbitmaps-resident   = lv_resident.
    wa_stxbitmaps-autoheight = 'X'.
    wa_stxbitmaps-bmcomp     = 'X'.
    INSERT INTO stxbitmaps VALUES wa_stxbitmaps.
    IF sy-subrc <> 0.
      UPDATE stxbitmaps FROM wa_stxbitmaps.
      IF sy-subrc <> 0.
        CONCATENATE 'Error: Graphic ' lv_name 'could not be saved (STXBITMAPS)' INTO p_message.
        p_return = 3.
**"          MESSAGE e285 WITH p_name 'STXBITMAPS'.
**        p_message = 'Graphic &1 could not be saved (2&)'.
**        PERFORM write_message CHANGING p_message.
      ENDIF.
    ENDIF.

* Set description in BDS attributes
    wa_bds_properties-prop_name  = 'DESCRIPTION'.
    wa_bds_properties-prop_value = lv_title.
    APPEND wa_bds_properties TO lv_bds_properties.
    CALL METHOD lv_bds_object->change_properties
      EXPORTING
        classname  = c_bds_classname
        classtype  = c_bds_classtype
        object_key = lv_object_key
        doc_id     = lv_docid
        doc_ver_no = '1'
        doc_var_id = '1'
      CHANGING
        properties = lv_bds_properties
      EXCEPTIONS
        OTHERS     = 1.
    PERFORM dequeue_graphic IN PROGRAM saplstxbitmaps USING lv_object
                                  lv_name
                                  lv_id
                                  lv_btype.
  ELSE.
    p_message = 'Error: Gagal Convert to Binary'.
    p_return = 4.
  ENDIF.

ENDFORM.                    " PROSES_FILE
*&---------------------------------------------------------------------*
*&      Form  WRITE_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_MESSAGE  text
*----------------------------------------------------------------------*
FORM write_message  CHANGING p_message.
  MESSAGE ID sy-msgid TYPE sy-msgty
                         NUMBER sy-msgno
                           WITH sy-msgv1
                                sy-msgv2
                                sy-msgv3
                                sy-msgv4
                           INTO p_message.

ENDFORM.                    " WRITE_MESSAGE
