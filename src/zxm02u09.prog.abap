*----------------------------------------------------------------------*
*   INCLUDE ZXM02U09                                                   *
*----------------------------------------------------------------------*
*"  IMPORTING
*"     REFERENCE(IM_REQ_HEADER) TYPE REF TO  IF_PURCHASE_REQUISITION
*"  EXPORTING
*"     REFERENCE(EX_NUMBER) TYPE  EBAN-BANFN
*"     REFERENCE(EX_RANGE) TYPE  T161-NUMKI
*"  EXCEPTIONS
*"      EXIT_ERROR
DATA: d_werks   TYPE eban-werks,
      ls_header TYPE mereq_header.

ls_header = im_req_header->get_data( ).
IF ls_header-bsart = 'ZPR'.
ELSE.
  GET PARAMETER ID 'M_WERKS' FIELD d_werks.
  SELECT SINGLE nkban FROM t399d INTO ex_range
  WHERE werks = d_werks.
ENDIF.
