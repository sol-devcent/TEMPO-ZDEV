*&---------------------------------------------------------------------*
*&  Include           ZTTACPP_E002TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_role,
          status          TYPE string,
          statuscode      TYPE string,
          message         TYPE string,
          role            TYPE string,
          id_u            TYPE string,
          id_rekanan      TYPE string,
          name            TYPE string,
          phone           TYPE string,
          email           TYPE string,
          token           TYPE string,
          remember_token  TYPE string,
          created_at_u    TYPE string,
          updated_at_u    TYPE string,
          deleted_u       TYPE string,
          status_u        TYPE string,
          verified        TYPE string,
          master          TYPE string,
          subaccount      TYPE string,
          id_s            TYPE string,
          id_group        TYPE string,
          nama_rekanan    TYPE string,
          alamat_rekanan  TYPE string,
          no_telp         TYPE string,
          fax             TYPE string,
          provinsi        TYPE string,
          kota            TYPE string,
          latitude        TYPE string,
          longitude       TYPE string,
          status_s        TYPE string,
          logo_rekanan    TYPE string,
          created_at_s    TYPE string,
          updated_at_s    TYPE string,
          deleted_s       TYPE string,
          file_dokumen    TYPE string,
          badan_usaha     TYPE string,
          npwp            TYPE string,
        END OF ty_role.

TYPES : BEGIN OF ty_zaccdta.
        INCLUDE STRUCTURE zaccdta.
TYPES :   check,
        END OF ty_zaccdta.

TYPES : BEGIN OF ty_response,
          status          TYPE string,
          statuscode      TYPE string,
          message         TYPE string,
          data            TYPE string,
        END OF ty_response.

TYPES : BEGIN OF ty_zaccdtm.
        INCLUDE STRUCTURE zaccdtm.
TYPES :   aggr1   TYPE zaccdta-aggr1,
          aggr2   TYPE zaccdta-aggr2,
          check,
        END OF ty_zaccdtm.

TYPES : BEGIN OF ty_error,
          description(20),
          process(30),
          response  TYPE sbcheader-header,
        END OF ty_error.

TYPES : BEGIN OF ty_report,
          desc(20),
          aufnr     TYPE s501-docno,
          aggr1     TYPE zaccdta-aggr1,
          aggr2     TYPE zaccdta-aggr2,
          senum     TYPE zaccdta-senum,
          docno     TYPE s501-docno,
          matnr     TYPE s501-matnr,
          charg     TYPE s501-charg,
          success   TYPE i,
          error     TYPE i,
        END OF ty_report.

DATA : gt_request_header   TYPE TABLE OF sbcheader WITH HEADER LINE,
       gt_request_body     TYPE TABLE OF sbcbody WITH HEADER LINE,
       gt_response_header  TYPE TABLE OF sbcheader WITH HEADER LINE,
       gt_response_body    TYPE TABLE OF sbcbody WITH HEADER LINE.

DATA : status_code(5),
       status_text(300).

DATA : gs_zaccdtl          TYPE zaccdtl,
       gt_zaccdtu          TYPE STANDARD TABLE OF zaccdtu,
       gt_s501             TYPE STANDARD TABLE OF s501,
       gt_zaccdta          TYPE STANDARD TABLE OF zaccdta,
       gt_zaccdtd          TYPE STANDARD TABLE OF zaccdtd,
       gt_zaccdtm          TYPE STANDARD TABLE OF zaccdtm,
       gt_ztspmmdt002      TYPE STANDARD TABLE OF ztspmmdt002,
       gt_mch1             TYPE STANDARD TABLE OF mch1,
       gt_error            TYPE STANDARD TABLE OF ty_error,
       gt_report           TYPE STANDARD TABLE OF ty_report,
       gt_list             TYPE STANDARD TABLE OF ty_report.

DATA : gv_subrc            TYPE sy-subrc,
       gv_subrc1           TYPE sy-subrc,
       gv_subrc2           TYPE sy-subrc,
       gv_subrc3           TYPE sy-subrc,
       gv_token            TYPE string,
       gv_idsarana         TYPE string,
       gv_concat.
