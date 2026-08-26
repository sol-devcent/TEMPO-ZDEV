@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Evaluation - PO History'
define view entity ZI_VEND_EVAL_PO_HIST
  as select from I_MaterialDocumentItem_2 as Hist
{
  key Hist.MaterialDocumentYear,
  key Hist.MaterialDocument,
  key Hist.MaterialDocumentItem,
      Hist.PurchaseOrder,
      Hist.PurchaseOrderItem,
      Hist.Material,
      Hist.Plant,
      Hist.GoodsMovementType,
      Hist.PostingDate,
      Hist.QuantityInEntryUnit,
      Hist.EntryUnit
}
where Hist.GoodsMovementType = '101'
   or Hist.GoodsMovementType = '102'
   or Hist.GoodsMovementType = '122'
   or Hist.GoodsMovementType = '123'
