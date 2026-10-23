class ZCL_ZTIAM_API_MPC_EXT definition
  public
  inheriting from ZCL_ZTIAM_API_MPC
  create public .

public section.


  types:
    BEGIN OF po_items,
        po_item               TYPE c LENGTH 6,
        acct_assignment       TYPE c LENGTH 2,
        item_category         TYPE c LENGTH 10,
        short_text            TYPE c LENGTH 40,
        material              TYPE c LENGTH 18,
        po_quantity           TYPE c LENGTH 15,
        order_unit            TYPE c LENGTH 5,
        material_group        TYPE c LENGTH 18,
        plant                 TYPE c LENGTH 4,
        zpb1_gross_price      TYPE c LENGTH 20,
        price_unit            TYPE c LENGTH 10,
        currency              TYPE c LENGTH 5,
        sequence_a_assignment TYPE c LENGTH 2,
        acc_assign_qty        TYPE c LENGTH 10,
        gl_account            TYPE c LENGTH 10,
        unloading_point       TYPE c LENGTH 30,
        cost_center           TYPE c LENGTH 20,
        requirement_number    TYPE c LENGTH 10,
        discount              type c LENGTH 20,
        curr_disc             type c LENGTH 5,
        schedule           TYPE STANDARD TABLE OF ts_PO_SCHEDULE WITH DEFAULT KEY,
      END OF po_items .
  types:
    BEGIN OF  ts_create_po_tiam ,
        proses           TYPE c LENGTH 15,
        po_web           TYPE c LENGTH 10,
        po_date          TYPE c LENGTH 10,
        po_type          TYPE c LENGTH 5,
        kode_vendor      TYPE c LENGTH 10,
        purchasing_org   TYPE c LENGTH 4,
        purchasing_group TYPE c LENGTH 3,
        company_code     TYPE c LENGTH 4,
        currency         TYPE c LENGTH 10,
        username         TYPE c LENGTH 12,
        "status           TYPE c LENGTH 1,
        po_sap           TYPE c LENGTH 20,
        type             type c LENGTH 1,
        message          type c LENGTH 220,
        items        TYPE STANDARD TABLE OF po_items WITH DEFAULT KEY, "ts_po_header with DEFAULT KEY, "
        error        TYPE STANDARD TABLE OF ts_po_error WITH DEFAULT KEY, "ts_po_header with DEFAULT KEY, "
      END OF ts_create_po_tiam .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZTIAM_API_MPC_EXT IMPLEMENTATION.
ENDCLASS.
