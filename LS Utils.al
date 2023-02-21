// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!




dotnet
{




    assembly("System.Drawing")
    {


        type("System.Drawing".Bitmap;
        Bitmap)
        {






        }


    }
    assembly("System.Drawing")
    {

        type("System.Drawing.Imaging".ImageFormat; ImageFormatd)
        {




        }


    }



}





codeunit 50004 AlamerPOSUtils
{



    var
        Publisher: Codeunit "POS Print Utility";
        PTrans: Codeunit "POS Transaction";
        FileMgt: Codeunit "File Management";
        QRCodeRec: Record TempBlob;
        ZQRCodeRec: Record TempBlob;

        RQRCodeRec: Record TempBlob;
        ServerQRPath: Text;
        FontType: Option "Normal","Bold";
        Text500: TextConst ENU = 'Table';
        Text367: TextConst ENU = 'ID';
        Text048: TextConst ENU = 'Date';
        gCompanyInfo: Record "Company Information";
        gVATAmount: Decimal;
        TransInventoryEntry: Record "Trans. Inventory Entry";
        Phase: Integer;
        PosGUI: Codeunit 99001575;
        //  POSTerminal: Record "POS Terminal";
        DSTR1: Text;
        Value: array[10] of Text;
        NodeName: array[10] of Text;
        POSFunctions: Codeunit "POS Functions";
        HospitalityType: Record "Hospitality Type";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Transaction Events", 'OnAfterInsertPaymentLine', '', true, true)]
    procedure OnAfterInsertPaymentLine(var CurrInput: Text; var POSTransaction: Record "POS Transaction"; var POSTransLine: Record "POS Trans. Line")
    var
        PTTrans: Codeunit "POS Transaction";
        MenuLine: Record "POS Menu Line";

    begin
        MenuLine.SetFilter("Menu ID", '#CANCEL');
        MenuLine.SetFilter("Profile ID", '##DEFAULT');
        MenuLine.SetFilter("Key No.", '1');
        if (MenuLine.Find('-'))
        then begin
            PTrans.RunCommand(MenuLine);
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Transaction Events", 'OnAfterChangeQty', '', true, true)]
    procedure OnAfterChangeQty(var CurrInput: Text; var POSTransaction: Record "POS Transaction"; var POSTransLine: Record "POS Trans. Line")
    var
        PTTrans: Codeunit "POS Transaction";
        MenuLine: Record "POS Menu Line";

    begin


        MenuLine.SetFilter("Menu ID", '#CANCEL');
        MenuLine.SetFilter("Profile ID", '##DEFAULT');
        MenuLine.SetFilter("Key No.", '1');
        if (MenuLine.Find('-'))
        then begin
            PTrans.RunCommand(MenuLine);
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Transaction Events", 'OnBeforeGetContext', '', true, true)]
    procedure OnAfterGetContext(var POSTransaction: Record "POS Transaction"; var CurrInput: Text; var POSTransLine: Record "POS Trans. Line")
    var
        CContact: Record "Contact";
        Terminal: Record "POS Terminal";
        CusName: Text;
        CusPhone: Text;
        EPOSCtrl: Codeunit "EPOS Control Interface";
    begin

        //  Message(Command);
        // Terminal.Reset();
        //Terminal.Get(POSTransaction."POS Terminal No.");

        /*
        if EPOSCtrl.loaded and (POSTransaction."Transaction Type" = POSTransaction."Transaction Type"::Sales) and (Terminal.Get(POSTransaction."POS Terminal No.")) then
            if (Terminal."Interface Profile" = '#BK-OVEN') and (POSTransaction."Sell-to Contact No." = '') then begin

                CusName := EPOSCtrl.GetInputText('#CUST_NAME');
                CusPhone := EPOSCtrl.GetInputText('#CUST_PHONE');


                if (StrLen(CusName) > 0)
                           then begin

                    CContact.Reset();
                    CContact.SetFilter("No.", CusPhone);
                    if (CContact.Find('-'))
                    then begin
                        CContact.Name := CusName;
                        CContact."Phone No." := CusPhone;
                        CContact.Modify();
                    end else begin
                        CContact.Init();
                        CContact."No." := CusPhone;
                        CContact.Name := CusName;
                        CContact."Phone No." := CusPhone;
                        CContact.Insert();
                    end;
                    POSTransaction."Sell-to Contact No." := CContact."No.";
                    POSTransaction.Modify();
                    //  EPOSCtrl.SetInputText('#CUST_NAME', '');
                    //  EPOSCtrl.SetInputText('#CUST_PHONE', '');
                end;
            end;



*/
    end;

    /// <summary>
    /// OnBeforeGetContext.
    /// </summary>
    /// <param name="gContext">DotNet "LSContextModel".</param>
    /// <param name="pContextModel">DotNet "LSContextModel".</param>
    /// <param name="CurrInput">VAR Text.</param>
    /// <param name="POSTransaction">VAR Record "POS Transaction".</param>
    /// <param name="POSTransLine">VAR Record "POS Trans. Line".</param>

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Transaction Events", 'OnAfterSuspend', '', true, true)]
    procedure OnAfterSuspend(var POSTransaction: Record "POS Transaction")
    var
        EPOSCtrl: Codeunit "EPOS Control Interface";
        CusName: Text;
        CusPhone: Text;
        CContact: Record "Contact";
        Terminal: Record "POS Terminal";

    begin

        Terminal.Get(POSTransaction."POS Terminal No.");
        if (Terminal."Interface Profile" = '#BK-OVEN') then begin

            // POSView.GetContext(lContext);
            CusName := EPOSCtrl.GetInputText('#CUST_NAME');
            CusPhone := EPOSCtrl.GetInputText('#CUST_PHONE');
            if (StrLen(CusName) > 0)
            then begin

                CContact.Reset();
                CContact.SetFilter("No.", CusPhone);
                if (CContact.Find('-'))
                then begin
                    CContact.Name := CusName;
                    CContact."Phone No." := CusPhone;
                    CContact.Modify();
                end else begin
                    CContact.Init();
                    CContact."No." := CusPhone;
                    CContact.Name := CusName;
                    CContact."Phone No." := CusPhone;
                    CContact.Insert();
                end;
                POSTransaction."Sell-to Contact No." := CContact."No.";
                POSTransaction.Modify();
                EPOSCtrl.SetInputText('#CUST_NAME', '');
                EPOSCtrl.SetInputText('#CUST_PHONE', '');
            end;
        end;
        // addCommand('CUSTOMER_INFO');

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Transaction Events", 'OnAfterRetSuspended', '', true, true)]
    procedure OnAfterRetSuspended(var POSTransaction: Record "POS Transaction")
    var
        EPOSCtrl: Codeunit "EPOS Control Interface";
        CusName: Text;
        CusPhone: Text;
        CContact: Record "Contact";
        Terminal: Record "POS Terminal";


    begin
        Terminal.Get(POSTransaction."POS Terminal No.");
        if (Terminal."Interface Profile" = '#BK-OVEN') then begin

            if not (POSTransaction."Sell-to Contact No." = '')
            then begin
                CContact.Reset();
                CContact.SetFilter("No.", POSTransaction."Sell-to Contact No.");
                if (CContact.Find('-'))
                then begin
                    EPOSCtrl.SetInputText('#CUST_NAME', CContact.Name);
                    EPOSCtrl.SetInputText('#CUST_PHONE', CContact."Phone No.");
                end else begin

                    EPOSCtrl.SetInputText('#CUST_NAME', '');
                    EPOSCtrl.SetInputText('#CUST_PHONE', '');
                end;
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Transaction Events", 'OnAfterStartNewTransaction', '', true, true)]
    procedure OnAfterStartNewTransaction(var POSTransaction: Record "POS Transaction")
    var
        EPOSCtrl: Codeunit "EPOS Control Interface";
        Terminal: Record "POS Terminal";
    begin
        // if(EPOSCtrl.getin)
        Terminal.Get(POSTransaction."POS Terminal No.");

        if (Terminal."Interface Profile" = '#BK-OVEN') then begin


            EPOSCtrl.SetInputText('#CUST_NAME', '');
            EPOSCtrl.SetInputText('#CUST_PHONE', '');
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Print Utility", 'OnBeforePrintKOTLine', '', true, true)]
    procedure OnBeforePrintKOTLine(var KOTHeader: Record "KOT Header"; PrintBuffer: Record "POS Print Buffer"; PrintBufferIndex: Integer; LinesPrinted: Integer; var Proceed: Boolean; var DSTR1: Text[100]; Value: array[10] of Text[120]; sender: Codeunit "POS Print Utility")
    VAR
        POSText: Record 99001492;
        LineLength: Integer;
        Terminal: Record 99001471;
        ReceiptHeader: Record 99001498;
        RetailUtil: Codeunit 99001462;
        ReceiptNo: Code[20];
        SeatNo: Integer;
        PosTrGuestInfo: Record 10012117;
        ResTbl: Record 10001206;
        KOTLineRouting: Record 10012127;
        KOTLineModifier: Record 10012128;
        KOTLine: Record 10012126;
        Quan: Text[30];
        Sts: Text[30];
        DelKOT: Text[30];
        KOTLineTEMP: Record 10012126 TEMPORARY;
        LastMenuTypeDescription: Text[30];

        Tray: Integer;
    begin
        Tray := 2;

        Value[1] := 'الكمية                            الوصف';
        DSTR1 := '#L#######################################';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.PrintSeperator(Tray);
        KOTLineRouting.RESET;
        KOTLineRouting.SETCURRENTKEY("KOT No.", "Display Station ID", "Line Printed");
        KOTLineRouting.SETRANGE("KOT No.", KOTHeader."KOT No.");
        KOTLineRouting.SETRANGE("Display Station ID", KOTHeader."Printer Station ID");
        //  IF NOT PrintAllLines THEN
        //      KOTLineRouting.SETFILTER("Line Printed", '<>%1', KOTLineRouting."Line Printed"::Yes);
        //      KOTLineRouting.SETFILTER("Line Printed", '<>%1', KOTLineRouting."Line Printed"::Yes);

        KOTLineTEMP.RESET;
        KOTLineTEMP.DELETEALL;
        IF KOTLineRouting.FINDSET THEN
            REPEAT
                IF KOTLine.GET(KOTLineRouting."KOT No.", KOTLineRouting."KOT Line No.") THEN BEGIN
                    KOTLineTEMP := KOTLine;
                    KOTLineTEMP."Line Printed" := KOTLineRouting."Line Printed";
                    IF KOTLineTEMP.INSERT THEN;
                END;
            UNTIL KOTLineRouting.NEXT = 0;

        KOTLineRouting.MODIFYALL("Line Printed", KOTLineRouting."Line Printed"::Yes);

        COMMIT;

        KOTLineTEMP.RESET;
        KOTLineTEMP.SETCURRENTKEY("KOT No.", "Menu Type");
        LastMenuTypeDescription := '';
        IF KOTLineTEMP.FINDSET THEN
            REPEAT
                IF KOTLineTEMP."Menu Type Description" <> LastMenuTypeDescription THEN BEGIN
                    sender.PrintLine(Tray, '');
                    Value[1] := KOTLineTEMP."Menu Type Description";
                    DSTR1 := '#L#######################################';
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                    LastMenuTypeDescription := KOTLineTEMP."Menu Type Description";
                END;
                //DSTR1 := '#L###################### #R####### #R###';
                DSTR1 := '#L############################ #R#######';
                Value[1] := '';
                IF KOTLineTEMP."Line Printed" IN [KOTLineTEMP."Line Printed"::Yes, KOTLineTEMP."Line Printed"::"Reprint-Modifier"] THEN
                    Value[1] := '*';
                IF KOTLineTEMP.Voided THEN
                    Value[1] += '(-)';
                Value[1] += KOTLineTEMP.Description;

                Value[2] := FORMAT(KOTLineTEMP.Quantity);
                sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                NodeName[1] := 'Item Description';
                NodeName[2] := 'Quantity';
                sender.AddPrintLine(300, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, 2);

                KOTLineModifier.RESET;
                KOTLineModifier.SETRANGE("KOT No.", KOTLineTEMP."KOT No.");
                KOTLineModifier.SETRANGE("KOT Line No.", KOTLineTEMP."KOT Line No.");
                // KOTLineModifier.SETFILTER("Line Type", '<>%1', KOTLineModifier."Line Type"::Ingredient);  //LS-12266
                IF KOTLineModifier.FINDSET(TRUE, FALSE) THEN
                    REPEAT

                        Message(KOTLineModifier.Description);
                        DSTR1 := '#L############################ #R#######';
                        Value[1] := '';
                        IF KOTLineModifier."Line Printed" = KOTLineModifier."Line Printed"::Yes THEN
                            Value[1] := '*';
                        IF KOTLineModifier.Voided THEN
                            Value[1] += '(-)';
                        Value[1] += KOTLineModifier.Description;
                        CASE KOTLineModifier."Line Info Type" OF
                            KOTLineModifier."Line Info Type"::Item:
                                Value[2] := FORMAT(KOTLineModifier.Quantity);
                            KOTLineModifier."Line Info Type"::Text:
                                IF KOTLineModifier.Quantity > 1 THEN
                                    Value[2] := FORMAT(KOTLineModifier.Quantity)
                                ELSE
                                    Value[2] := '';
                        END;
                        sender.PrintLine(2, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                        NodeName[1] := 'Item Description';
                        NodeName[2] := 'Quantity';
                        sender.AddPrintLine(350, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, 2);
                        IF KOTLineModifier."Line Printed" <> KOTLineModifier."Line Printed"::Yes THEN BEGIN
                            KOTLineModifier."Line Printed" := KOTLineModifier."Line Printed"::Yes;
                            KOTLineModifier.MODIFY;
                        END;
                    UNTIL KOTLineModifier.NEXT = 0;
            UNTIL KOTLineTEMP.NEXT = 0;
        COMMIT;
        Proceed := false;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Print Utility", 'OnBeforePrintHeader', '', true, true)]
    procedure OnBeforePrintHeader(Transaction: Record "Transaction Header"; PreReceipt: Boolean; Tray: Integer; PrintBuffer: Record "POS Print Buffer"; PrintBufferIndex: Integer; LinesPrinted: Integer; var Proceed: Boolean; sender: Codeunit "POS Print Utility"; Globals: Codeunit "POS Session"; UseTransactionStoreAndPOSForPrintHeader: Boolean)
    begin
        Proceed := false;
        PrintHeader(Transaction, PreReceipt, Tray, sender, Globals, UseTransactionStoreAndPOSForPrintHeader);


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Print Utility", 'OnBeforePrintSubHeader', '', true, true)]
    procedure OnBeforePrintSubHeader(TransactionHeader: Record "Transaction Header"; Tray: Integer; PrintBuffer: Record "POS Print Buffer"; PrintBufferIndex: Integer; LinesPrinted: Integer; var Proceed: Boolean; sender: Codeunit "POS Print Utility"; LineLen: Integer)
    begin
        Proceed := false;
        PrintSubHeader(TransactionHeader, Tray, TransactionHeader.Date, TransactionHeader.Time, sender, LineLen, LinesPrinted);


    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Transaction Events", 'OnBeforeAskForCard', '', true, true)]
    procedure OnBeforeAskForCard(var CurrInput: Text; var PaymentAmount: Decimal; var POSTransaction: Record "POS Transaction"; var POSTransLine: Record "POS Trans. Line"; var Proceed: Boolean)
    var
        POSEFT: Codeunit "POS EFT Utility";
        // PEFT2: Page "EPOS EFT Dialog";
        POSTransactionCU: Codeunit "POS Transaction";
        POSEFTRecord: Record "POS EFT";
        POSTerminal: Record "POS Terminal";
        POSCardEntry: Record "POS Card Entry";
        CardEntryNo: Integer;
        Description: Text[200];
        POSHardwareprofile: Record "POS Hardware Profile";
        DeviceID: Code[20];
    begin
        POSTerminal.Get(POSTransaction."POS Terminal No.");
        if not (POSTerminal."Hardware Profile" = '') then begin


            POSHardwareprofile.Get(POSTerminal."Hardware Profile");


            if (POSHardwareprofile."HWST Sync") and (POSTerminal."EFT Authentication Type" = POSTerminal."EFT Authentication Type"::WIFI) then begin




                Proceed := false;
                //  Message('ask for card');
                POSEFT.ClearEFT();


                POSEFT.InitEFTServer();
                Description := '';
                //  POSEFT.SeekAuth();
                POSEFT.SetAmount(PaymentAmount);
                POSEFT.SetTransType(POSCardEntry."Transaction Type"::Sale);
                POSEFT.PollStatus(Description);

                /*
                if (POSHardwareprofile.GetDevice(6, '', '', 0, DeviceID))
then
                    if (POSEFTRecord.Get(DeviceID)) then;

                    PEFT2.Purchase(POSEFT.get);
                POSEFT.PollStatus(Description);
                
          
                Clear(PEFT2);
                PEFT2.SetDemoMode(POSHardwareprofile.EFT = POSHardwareprofile.EFT::None);

*/


                POSEFT.InitLogEntry(POSTransaction."Receipt No.");
                //POSEFT.SetTenderType('3');
                CardEntryNo := POSEFT.InsertLogEntry();
                POSCardEntry.Reset();
                POSCardEntry.SetFilter("Store No.", POSTransaction."Store No.");
                POSCardEntry.SetFilter("POS Terminal No.", POSTransaction."POS Terminal No.");
                POSCardEntry.SetFilter("Entry No.", format(CardEntryNo));
                //Message(FORMAT(CardEntryNo));
                POSTransactionCU.InsertCardPaymentLine(CardEntryNo);
                if (POSCardEntry.Find('-')) then begin
                    if (POSCardEntry."Authorisation Ok") then begin
                        POSCardEntry."Auth.code" := POSCardEntry."EFT Batch No.";
                        POSCardEntry.Modify();
                        POSTransactionCU.InsertPaymentLine();

                    end;
                end;
                POSEFT.CloseEFTServer();

            end;
        end;

    end;




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Print Utility", 'OnBeforePrintSlips', '', true, true)]
    procedure PrintTest(QRPath: Text[250]; bSecondPrintActive: Boolean; sender: Codeunit "POS Print Utility"; GenPosFunc: Record "POS Functionality Profile";
     PrintBuffer: Record "POS Print Buffer"; PrintBufferIndex: Integer; LinesPrinted: Integer; var Proceed: Boolean; ActivePrintHeader: Record "POS Print Header";
      Globals: Codeunit "POS Session"; PosSetup: Record "POS Hardware Profile"; LastErrorText: Text; POSFunctions: Codeunit "POS Functions";
       var Transaction: Record "Transaction Header"; LineLen: Integer; InvLineLen: Integer; IsInvoice: Boolean; UseTransactionStoreAndPOSForPrintHeader: Boolean);
    var

        TransSalesEntry: Record "Trans. Sales Entry";
        PaymentEntry: Record 99001474;

        TransIncExpEntry: Record 99001475;
        TenderType: Record 99001462;
        POSTerminal: Record 99001471;

        MsgTxt: Text[50];
        PrintInvoice: Boolean;
        DestPhase: Integer;
        PrintSlip: Boolean;

    begin



        DestPhase := Phase;
        /*
                IF NOT PTrans.PosConfirm('هل تريد طباعة الفاتورة؟' + Transaction."Receipt No." + FORMAT(Transaction."Transaction Type"), FALSE) THEN begin
                    Proceed := false;

                    exit;
                end;
        */

        MsgTxt := '';
        PrintInvoice := FALSE;

        PaymentEntry.SETRANGE("Store No.", Transaction."Store No.");
        PaymentEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
        PaymentEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
        Phase := 1;

        IF Transaction."Entry Status" = Transaction."Entry Status"::Voided THEN BEGIN
            IF NOT sender.PrintVoidSlip(Transaction) THEN
                EXIT;
        END
        ELSE BEGIN
            HospitalityType.RESET;
            HospitalityType.SETRANGE("Restaurant No.", Transaction."Store No.");
            HospitalityType.SETRANGE("Sales Type", Transaction."Sales Type");
            IF NOT HospitalityType.FINDFIRST THEN
                CLEAR(HospitalityType);
            CASE Transaction."Transaction Type" OF
                Transaction."Transaction Type"::Sales, Transaction."Transaction Type"::Payment:
                    BEGIN


                        // Proceed := false;
                        //  posutils.printReceipt('', '');


                        //   PrintSalesSlip(sender, Transaction, GenPosFunc, PrintBuffer, bSecondPrintActive, QRPath, LineLen, InvLineLen, IsInvoice, PrintBufferIndex, Globals,UseTransactionStoreAndPOSForPrintHeader);

                        Phase := Phase + 1;
                        Phase := Phase + 1;
                        TransSalesEntry.SETRANGE("Store No.", Transaction."Store No.");
                        TransSalesEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
                        TransSalesEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
                        IF TransSalesEntry.FIND('-') THEN
                            REPEAT
                                Phase := Phase + 1;
                                IF Phase >= DestPhase THEN
                                    IF NOT sender.PrintExtraItem(TransSalesEntry) THEN
                                        EXIT;
                            UNTIL TransSalesEntry.NEXT = 0;

                        TransIncExpEntry.SETRANGE("Store No.", Transaction."Store No.");
                        TransIncExpEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
                        TransIncExpEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
                        IF TransIncExpEntry.FIND('-') THEN
                            REPEAT
                                Phase := Phase + 1;
                                IF Phase >= DestPhase THEN
                                    IF NOT sender.PrintExtraIncomeExpense(TransIncExpEntry) THEN
                                        EXIT;
                            UNTIL TransIncExpEntry.NEXT = 0;

                        IF PaymentEntry.FIND('-') THEN
                            REPEAT
                                IF TenderType.GET(PaymentEntry."Store No.", PaymentEntry."Tender Type") THEN BEGIN
                                    IF (TenderType."Function" = TenderType."Function"::Customer) AND (PaymentEntry."Amount Tendered" <> 0) THEN
                                        IF Phase >= DestPhase THEN
                                            IF NOT Transaction."Post as Shipment" THEN
                                                IF NOT sender.PrintCustomerSlip(PaymentEntry) THEN
                                                    EXIT;
                                    Phase := Phase + 1;
                                    IF TenderType."Front of Check" THEN
                                        IF Phase >= DestPhase THEN
                                            IF NOT sender.PrintCheckFront(PaymentEntry) THEN
                                                EXIT;
                                    Phase := Phase + 1;
                                    IF TenderType."Endorse Check" THEN
                                        IF Phase >= DestPhase THEN
                                            IF NOT sender.PrintCheckBack(PaymentEntry) THEN
                                                EXIT;
                                    Phase := Phase + 1;
                                    IF Phase >= DestPhase THEN
                                        IF NOT sender.PrintExtraPayment(PaymentEntry) THEN
                                            EXIT;
                                    IF Phase >= DestPhase THEN
                                        sender.PrintVoucherRemainingAmt(PaymentEntry);

                                    Phase := Phase + 1;
                                    IF TenderType."Print Separate Invoice" THEN BEGIN
                                        MsgTxt := TenderType."Invoice in Printer";
                                        PrintInvoice := TRUE;
                                    END;
                                END;
                            UNTIL PaymentEntry.NEXT = 0;
                        IF Phase >= DestPhase THEN
                            IF NOT sender.PrintAllIssuedCoupons(Transaction) THEN
                                EXIT;
                        IF PrintInvoice THEN
                            IF Phase >= DestPhase THEN
                                IF NOT sender.PrintSalesInvoice(Transaction, MsgTxt) THEN
                                    EXIT;
                        Phase := Phase + 1;
                        //    IF Transaction."Sale Is Return Sale" THEN
                        // IF Phase >= DestPhase THEN
                        //  IF NOT sender.PrintReturnsSlip(Transaction) THEN
                        //      EXIT;
                        Phase := Phase + 1;
                        IF Phase >= DestPhase THEN BEGIN
                            PrintSlip := TRUE;
                            POSTerminal.GET(Transaction."POS Terminal No.");
                            IF NOT Transaction."Sale Is Return Sale" THEN BEGIN
                                IF POSTerminal."Sales Slip" = POSTerminal."Sales Slip"::None THEN
                                    PrintSlip := FALSE
                                ELSE
                                    IF POSTerminal."Sales Slip" = POSTerminal."Sales Slip"::"Print on Confirmation" THEN
                                        PrintSlip := POSGUI.PosConfirm('Print Sales Slip?', TRUE);
                            END;
                            IF PrintSlip THEN BEGIN



                                IF NOT PrintSalesSlip(sender, Transaction, GenPosFunc, PrintBuffer, bSecondPrintActive, QRPath, LineLen, InvLineLen, IsInvoice, PrintBufferIndex, Globals, UseTransactionStoreAndPOSForPrintHeader) THEN
                                    EXIT;






                                IF NOT sender.PrintSpoOrderConfirm(Transaction) THEN
                                    EXIT;
                            END;
                        END;







                    end;


                Transaction."Transaction Type"::NegAdj:
                    BEGIN

                        //  Proceed := false;
                        //  posutils.printReceipt('', '');


                        PrintNegAdjSlip(sender, Transaction, GenPosFunc, PrintBuffer, False, '', 40, 40, False, PrintBufferIndex, Globals);

                    end;
            end;
        end;

        Transaction."Transaction Type" := Transaction."Transaction Type"::Collect;


    end;

    procedure PrintNegAdjSlip(sender: Codeunit "POS Print Utility"; VAR Transaction: Record "Transaction Header";
     GenPosFunc: Record "POS Functionality Profile"; PrintBuffer: Record "POS Print Buffer";
      bSecondPrintActive: Boolean; QRPath: Text[250]; LineLen: Integer; InvLineLen: Integer; IsInvoice: Boolean; PrintBufferIndex: Integer; Globals: Codeunit "POS Session"): Boolean

    var
        ItemVariant: Record "Item Variant";
        Item: Record "Item";
        Descr: Text;
        POSTerminal: Record "POS Terminal";



    begin




        //LS-12824+
        IF Transaction."Transaction No." = 0 THEN
            EXIT(TRUE);

        sender.WindowInitialize();
        IF GenPosFunc."Neg. Adj. Slip Report ID" <> 0 THEN BEGIN
            Transaction.SETRANGE("Store No.", Transaction."Store No.");
            Transaction.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
            Transaction.SETRANGE("Transaction No.", Transaction."Transaction No.");
            REPORT.RUN(GenPosFunc."Neg. Adj. Slip Report ID", FALSE, TRUE, Transaction);
        END ELSE BEGIN

            POSTerminal.GET(Transaction."POS Terminal No.");
            IF NOT POSTerminal."Print Receipt for Neg. Adj." THEN
                EXIT(TRUE);

            IF NOT sender.OpenReceiptPrinter(2, 'NEG_ADJ', '', Transaction."Transaction No.", Transaction."Receipt No.") THEN
                EXIT(FALSE);

            //  sender.PrintLogo(2);

            sender.PrintBitmap(2, 'C:\Logo\Logo.BMP', 1);
            // sender.PrintHeader(Transaction, FALSE, 2);

            DSTR1 := '#C##################';
            Value[1] := 'استهلاك داخلي';
            NodeName[1] := 'الوصف';
            sender.PrintLine(2, sender.FormatLine(sender.FormatStr(Value, DSTR1), TRUE, TRUE, TRUE, FALSE));
            sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, TRUE, TRUE, TRUE, FALSE, 2);
            sender.PrintSeperator(2);



            PrintNegAdjSubHeader(Transaction, 2, Transaction.Date, Transaction.Time, sender, LineLen, InvLineLen);


            TransInventoryEntry.SETRANGE("Store No.", Transaction."Store No.");
            TransInventoryEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
            TransInventoryEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
            IF TransInventoryEntry.FIND('-') THEN BEGIN
                DSTR1 := '#L############# #L########### #L########';
                Value[1] := 'رقم';
                Value[2] := 'الوصف';
                Value[3] := 'الكمية';

                sender.PrintLine(2, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                sender.PrintSeperator(2);
                REPEAT

                    IF TransInventoryEntry."Variant Code" <> '' THEN
                        Value[1] := TransInventoryEntry."Item No." + '/' + TransInventoryEntry."Variant Code"
                    ELSE
                        Value[1] := TransInventoryEntry."Item No.";

                    IF (TransInventoryEntry."Variant Code" <> '') AND
                       ItemVariant.GET(TransInventoryEntry."Item No.", TransInventoryEntry."Variant Code") AND
                       (ItemVariant.Description <> '') THEN
                        Descr := ItemVariant.Description
                    ELSE BEGIN
                        Item.GET(TransInventoryEntry."Item No.");
                        Descr := Item.Description;
                    END;
                    NodeName[1] := 'x';
                    Value[2] := Descr;
                    NodeName[2] := 'الوصف';
                    IF TransInventoryEntry."Unit of Measure" = '' THEN
                        TransInventoryEntry."Unit of Measure" := '';

                    IF TransInventoryEntry."UOM Quantity" <> 0 THEN
                        Value[3] := POSFunctions.FormatQty(TransInventoryEntry."UOM Quantity") + ' ' +
                                                         LOWERCASE(TransInventoryEntry."Unit of Measure")
                    ELSE
                        Value[3] := POSFunctions.FormatQty(TransInventoryEntry.Quantity) + ' ' +
                                                         LOWERCASE(TransInventoryEntry."Unit of Measure");
                    NodeName[3] := 'x';
                    Value[4] := FORMAT(TransInventoryEntry."Line No.");
                    NodeName[4] := 'Line No.';
                    Value[5] := TransInventoryEntry."Item No.";
                    NodeName[5] := 'Item No.';
                    Value[6] := TransInventoryEntry."Variant Code";
                    NodeName[6] := 'Variant Code';
                    Value[7] := TransInventoryEntry."Unit of Measure";
                    NodeName[7] := 'UOM ID';
                    IF TransInventoryEntry."UOM Quantity" <> 0 THEN
                        Value[8] := POSFunctions.FormatQty(TransInventoryEntry."UOM Quantity")
                    ELSE
                        Value[8] := POSFunctions.FormatQty(TransInventoryEntry.Quantity);
                    NodeName[8] := 'Quantity';
                    sender.PrintLine(2, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    sender.AddPrintLine(300, 8, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, 2);
                UNTIL TransInventoryEntry.NEXT = 0;
                sender.PrintSeperator(2);
            END;

            sender.PrintFooter(Transaction, 2);

            IF NOT sender.ClosePrinter(2) THEN
                EXIT(FALSE);

        END;

        Transaction.IncPrintedCounter(1);
        COMMIT;



    end;

    procedure PrintSalesSlip(sender: Codeunit "POS Print Utility"; VAR Transaction: Record "Transaction Header";
     GenPosFunc: Record "POS Functionality Profile"; PrintBuffer: Record "POS Print Buffer";
      bSecondPrintActive: Boolean; QRPath: Text[250]; LineLen: Integer; InvLineLen: Integer; IsInvoice: Boolean; PrintBufferIndex: Integer; Globals: Codeunit "POS Session"; UseTransactionStoreAndPOSForPrintHeader: Boolean): Boolean

    //PrintSalesSlip
    var
        CurrentPrintID: Integer;
        POSTerminal: Record "POS Terminal";
        POSHardwareProfile: Record "POS Hardware Profile";
        FiscalON: Boolean;
        OnlyFiscal: Boolean;
        Bitmap: DotNet Bitmap;
        ImageFormat: DotNet ImageFormatd;
        InStr: InStream;
        OutStr: OutStream;
        AlamerUtils: Codeunit InvoiceUtils;
        ZlQRPath: Text;
        RlQRPath: Text;
        pQRPath: Text;
        Store: Record Store;
        LinesPrinted: Integer;

        exMsg: Text;
        grossamnt: Decimal;



    //LS-12824-
    begin
        FiscalON := FALSE;
        OnlyFiscal := TRUE;
        CurrentPrintID := 100;


        LinesPrinted := 0;






        //LS-12824+
        IF Transaction."Transaction No." = 0 THEN
            EXIT(TRUE);
        POSTerminal.GET(Transaction."POS Terminal No.");

        if (POSTerminal."Hardware Profile" = '') then begin
            POSHardwareProfile.Get(Store."Hardware Profile");
        end else begin
            POSHardwareProfile.Get(POSTerminal."Hardware Profile");
        end;

        sender.WindowInitialize();
        IF GenPosFunc."Sales Slip Report ID" <> 0 THEN BEGIN
            Transaction.SETRANGE("Store No.", Transaction."Store No.");
            Transaction.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
            Transaction.SETRANGE("Transaction No.", Transaction."Transaction No.");
            REPORT.RUN(GenPosFunc."Sales Slip Report ID", FALSE, TRUE, Transaction);
        END ELSE BEGIN

            POSTerminal.GET(Transaction."POS Terminal No.");

            IF Transaction.GetPrintedCounter(1) > 0 THEN BEGIN
                IF NOT sender.OpenReceiptPrinter(2, 'SALES', 'COPY', Transaction."Transaction No.", Transaction."Receipt No.") THEN
                    EXIT(FALSE);
            END
            ELSE BEGIN
                IF NOT sender.OpenReceiptPrinter(2, 'SALES', '', Transaction."Transaction No.", Transaction."Receipt No.") THEN
                    EXIT(FALSE);
            END;

            IF FiscalON THEN BEGIN
                IF NOT sender.FiscalPrint(Transaction, PrintBuffer.FiscalLineType::Sale) THEN
                    EXIT(FALSE);

                IF OnlyFiscal THEN BEGIN
                    IF sender.ClosePrinter(2) THEN BEGIN
                        bSecondPrintActive := FALSE;
                        Transaction.IncPrintedCounter(1);
                        COMMIT;
                        EXIT(TRUE);
                    END
                    ELSE
                        EXIT(FALSE);
                END;
            END;

            Store.SetFilter("No.", Transaction."Store No.");
            Store.FindFirst();

            //PrintPreHeader(Transaction,2,Transaction.Date,Transaction.Time);
            //  sender.PrintLogo(2);
            sender.PrintBitmap(2, POSHardwareProfile.Logo, 1);

            // PrintLogo(2, PrintBuffer, PrintBufferIndex, LinesPrinted, 1, Store."Print Receipt Bitmap No.");
            PrintHeader(Transaction, FALSE, 2, sender, Globals, UseTransactionStoreAndPOSForPrintHeader);


            IF Globals.GetValue('PrintEnglish') = '1' THEN BEGIN
                PrintSubHeaderENG(Transaction, 2, Transaction.Date, Transaction.Time, sender, LineLen, InvLineLen);

            end else begin

                PrintSubHeader(Transaction, 2, Transaction.Date, Transaction.Time, sender, LineLen, InvLineLen);

            end;

            //EDMABODON20201101: Print Barcode in Header ++
            IF POSTerminal."Receipt Barcode" AND NOT Transaction."Sale Is Return Sale" THEN BEGIN
                //EDMABODON_Sayed_20200819: PrintQR Code ++



                if (POSHardwareProfile."HWST Sync") then begin


                    pQRPath := AlamerUtils.getAmrBarcode(RQRCodeRec, Transaction."Receipt No.", 900, 100, POSHardwareProfile."HWST Host" + ':8094');
                end else begin

                    pQRPath := AlamerUtils.getClientAmrBarcode(RQRCodeRec, Transaction."Receipt No.", 900, 100);

                end;
                sender.PrintBitmap(2, pQRPath, 1);
                // Message(pQRPath);

                //   PrintBitmap(2, pQRPath, 1, PrintBuffer, PrintBufferIndex, 1, LinesPrinted);

                sender.PrintSeperator(2);
                //EDMABODON_Sayed_20200819: PrintQR Code ++
            END;

            IF Globals.GetValue('PrintEnglish') = '1' THEN BEGIN
                PrintSalesInfoEng(Transaction, 2, GenPosFunc, sender, IsInvoice, bSecondPrintActive, LineLen);
                Globals.SetValue('PrintEnglish', '0');
            end else begin

                PrintSalesInfo(Transaction, 2, GenPosFunc, sender, IsInvoice, bSecondPrintActive, LineLen);

            end;



            //  sender.PrintSalesInfo(Transaction, 2);
            IF Transaction."Member Card No." <> '' THEN
                sender.PrintLoyalty(Transaction, 2);

            //sender. PrintRecommendation(Transaction);

            sender.PrintFooter(Transaction, 2);

            //EDM_HDeek_20211019: ZakatQR++

            gCompanyInfo.GET;
            CLEAR(exMsg);


            if not (Transaction."Sale Is Return Sale")
            then begin
                grossamnt := -Transaction."Gross Amount";
                if (POSHardwareProfile."HWST Sync") then begin

                    ZlQRPath := AlamerUtils.getZakatQr(ZQRCodeRec, Transaction.Date, Transaction.Time, gCompanyInfo."Name 2", gCompanyInfo."VAT Registration No.", grossamnt, gVATAmount, POSHardwareProfile."HWST Host" + ':8094');

                end else begin
                    ZlQRPath := AlamerUtils.getClientZakatQr(ZQRCodeRec, Transaction.Date, Transaction.Time, gCompanyInfo."Name 2", gCompanyInfo."VAT Registration No.", grossamnt, gVATAmount);

                end;
                // ZlQRPath := FileMgt.BLOBExport(ZQRCodeRec, 'QrBmpExp.bmp', FALSE);
                //  Message(ZlQRPath);

                //  QRPath := FileMgt.DownloadTempFile(ZlQRPath);
                sender.PrintBitmap(2, ZlQRPath, 1);
                // PrintBitmap(2, ZlQRPath, 1, PrintBuffer, PrintBufferIndex, 1, LinesPrinted);

                //EDM_HDeek_20211019: ZakatQR--
            end;

            IF Transaction."Post as Shipment" THEN
                sender.PrintSignature('');



            IF NOT sender.ClosePrinter(2) THEN
                EXIT(FALSE);


            bSecondPrintActive := FALSE;
            Transaction.IncPrintedCounter(1);
            COMMIT;
            EXIT(TRUE);
        END;
    end;


    procedure CreateQRCode(Link: Text; VAR pQRCodeRec: Record TempBlob)
    var
        QRCodeText: Text[90];
        BOUtils_g: Codeunit "BO Utils";
    begin
        //CreateQRCode

        QRCodeText := Link;
        // Publisher.BOUtils_g.GetQRCode2(QRCodeText,pQRCodeRec); //LS-13093
        BOUtils_g.GetQRCode2(QRCodeText, pQRCodeRec);

    end;

    procedure PrintSubHeader(VAR Transaction: Record "Transaction Header"; Tray: Integer; PrDate: Date; PrTime: Time; sender: Codeunit "POS Print Utility"; LineLen: Integer; InvLineLen: Integer)

    //PrintSubHeader
    //LS-12346-
    var
        StaffName: Text;
        blankStr: Text;
        DSTR1: Text;

        Value: array[4] of Text;
        NodeName: array[4] of Text;
        Staff: Record Staff;
        CustomerRec: Record Customer;
        TransType: Text;



    begin


        if (Transaction."To Account")
        then begin
            TransType := 'مبيعات آجلة'
        end else begin

            TransType := 'مبيعات نقدية'
        end;




        CustomerRec.SetFilter("No.", Transaction."Customer No.");

        CustomerRec.FindFirst();


        //LS-12346+
        IF Tray = 2 THEN
            blankStr := sender.StringPad(' ', LineLen - 38)
        ELSE
            IF Tray = 4 THEN
                blankStr := sender.StringPad(' ', InvLineLen - 38);

        IF blankStr = '' THEN
            blankStr := ' ';

        //EDMABODON_20201104: Add Header ++
        // DSTR1 := '#C################################################';
        // Value[1] := '';
        // sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        // sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201104: Add Header --

        CLEAR(Value);
        DSTR1 := '#R#####################' + blankStr + '#R#############';
        Value[1] := Transaction."Receipt No.";
        NodeName[1] := 'Receipt No.';
        NodeName[1] := 'رقم الإيصال';
        Value[2] := 'رقم الإيصال';
        NodeName[2] := 'x';

        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        StaffName := Transaction."Staff ID";
        IF Staff.GET(Transaction."Staff ID") THEN
            StaffName := Staff."Name on Receipt";

        CLEAR(Value);
        DSTR1 := '#R########## #R########' + blankStr + '#R#############';
        Value[1] := FORMAT(PrTime, 0, '<Hours12>:<Minutes,2>:<Seconds,2> <AM/PM>');
        NodeName[1] := 'Trans. Time';
        //Value[2] := FORMAT(PrDate);
        Value[2] := FORMAT(PrDate, 0, '<Day,2>/<Month,2>/<Year4>');
        NodeName[2] := 'Trans. Date';
        Value[3] := Text048 + ':';
        Value[3] := ':' + 'التاريخ';
        NodeName[3] := 'x';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 3, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        IF Transaction.Comment <> '' THEN BEGIN
            CLEAR(Value);
            DSTR1 := '#R########' + blankStr + '#R############';
            IF Transaction."Table No." <> 0 THEN
                Value[1] := Text500 + ':'
            ELSE
                Value[1] := Text367 + ':';
            NodeName[1] := 'x';
            Value[2] := FORMAT(Transaction.Comment);
            NodeName[2] := 'x';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            sender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        END;
        //sender.PrintSeperator(Tray);


        //EDMABODON_20201101: ++
        CLEAR(Value);
        DSTR1 := '#R##################' + blankStr + '#R################';
        Value[2] := 'المحاسب';
        NodeName[2] := 'x';
        //Value[1] := StaffName;
        Value[1] := Transaction."Staff ID";
        NodeName[1] := 'x';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201101: --
        //EDMABODON_20201001: Add Terminal ++
        DSTR1 := '#R##################' + blankStr + '#R################';
        Value[1] := Transaction."POS Terminal No.";
        Value[2] := 'الكاونتر';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201001: Add Terminal --

        //EDMABODON_20201001: Add Agent ++
        DSTR1 := '#R##################' + blankStr + '#R################';
        Value[1] := TransType;
        Value[2] := ':' + 'النوع';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201001: Add Agent --


        //EDMABODON_20201001: Add Customer ++
        DSTR1 := '#R##################' + blankStr + '#R################';
        Value[1] := CustomerRec."No." + ' ' + CustomerRec.Name;
        Value[2] := ':' + 'العميل';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201001: Add Customer --

        //EDMABODON_20201001: Add VAT Registration ++
        gCompanyInfo.GET;
        DSTR1 := '#R##################' + blankStr + '#R################';
        Value[1] := gCompanyInfo."VAT Registration No.";
        Value[2] := ':' + 'الرقم الضريبي';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201001: Add VAT Registration --
        sender.PrintSeperator(Tray);
    end;

    procedure PrintSubHeaderENG(VAR Transaction: Record "Transaction Header"; Tray: Integer; PrDate: Date; PrTime: Time; sender: Codeunit "POS Print Utility"; LineLen: Integer; InvLineLen: Integer)

    //PrintSubHeader
    //LS-12346-
    var
        StaffName: Text;
        blankStr: Text;
        DSTR1: Text;

        Value: array[4] of Text;
        NodeName: array[4] of Text;
        Staff: Record Staff;
        CustomerRec: Record Customer;
        TransType: Text;



    begin


        if (Transaction."To Account")
        then begin
            TransType := 'مبيعات آجلة'
        end else begin

            TransType := 'مبيعات نقدية'
        end;




        CustomerRec.SetFilter("No.", Transaction."Customer No.");

        CustomerRec.FindFirst();


        //LS-12346+
        IF Tray = 2 THEN
            blankStr := sender.StringPad(' ', LineLen - 38)
        ELSE
            IF Tray = 4 THEN
                blankStr := sender.StringPad(' ', InvLineLen - 38);

        IF blankStr = '' THEN
            blankStr := ' ';

        //EDMABODON_20201104: Add Header ++
        // DSTR1 := '#C################################################';
        // Value[1] := '';
        // sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        // sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201104: Add Header --

        CLEAR(Value);
        DSTR1 := '#L#############' + blankStr + '#L#####################';
        Value[1] := 'Receipt No.';
        Value[2] := Transaction."Receipt No.";
        NodeName[2] := 'x';

        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        StaffName := Transaction."Staff ID";
        IF Staff.GET(Transaction."Staff ID") THEN
            StaffName := Staff."Name on Receipt";

        CLEAR(Value);
        DSTR1 := '#L#############' + blankStr + '#R######## #N###############';
        Value[3] := FORMAT(PrTime, 0, '<Hours12>:<Minutes,2>:<Seconds,2> <AM/PM>');
        NodeName[1] := 'Trans. Time';
        //Value[2] := FORMAT(PrDate);
        Value[2] := FORMAT(PrDate, 0, '<Day,2>/<Month,2>/<Year4>');
        NodeName[2] := 'Trans. Date';
        Value[1] := 'Trans. Date:';
        NodeName[3] := 'x';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 3, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        IF Transaction.Comment <> '' THEN BEGIN
            CLEAR(Value);
            DSTR1 := '#L#### #T############################';
            IF Transaction."Table No." <> 0 THEN
                Value[1] := Text500 + ':'
            ELSE
                Value[1] := Text367 + ':';
            NodeName[1] := 'x';
            Value[2] := FORMAT(Transaction.Comment);
            NodeName[2] := 'x';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            sender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        END;
        //sender.PrintSeperator(Tray);


        //EDMABODON_20201101: ++
        CLEAR(Value);
        DSTR1 := '#L##################' + blankStr + '#L################';
        Value[1] := 'Staff:';
        NodeName[2] := 'x';
        //Value[1] := StaffName;
        Value[2] := Transaction."Staff ID";
        NodeName[1] := 'x';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201101: --
        //EDMABODON_20201001: Add Terminal ++
        DSTR1 := '#L##################' + blankStr + '#L################';
        Value[2] := Transaction."POS Terminal No.";
        Value[1] := 'Counter:';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201001: Add Terminal --

        /*
                //EDMABODON_20201001: Add Agent ++
                DSTR1 := '#R##################' + blankStr + '#R################';
                Value[1] := TransType;
                Value[2] := ':' + 'Type';
                sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
                //EDMABODON_20201001: Add Agent --
        */

        //EDMABODON_20201001: Add Customer ++
        DSTR1 := '#L##################' + blankStr + '#L################';
        Value[2] := CustomerRec."No." + ' ' + CustomerRec.Name;
        Value[1] := 'Customer:';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201001: Add Customer --

        //EDMABODON_20201001: Add VAT Registration ++
        gCompanyInfo.GET;
        DSTR1 := '#L##################' + blankStr + '#L################';
        Value[2] := gCompanyInfo."VAT Registration No.";
        Value[1] := 'VAT No.';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201001: Add VAT Registration --
        sender.PrintSeperator(Tray);
    end;

    procedure PrintNegAdjSubHeader(VAR Transaction: Record "Transaction Header"; Tray: Integer; PrDate: Date; PrTime: Time; sender: Codeunit "POS Print Utility"; LineLen: Integer; InvLineLen: Integer)

    //PrintSubHeader
    //LS-12346-
    var
        StaffName: Text;
        blankStr: Text;
        DSTR1: Text;

        Value: array[4] of Text;
        NodeName: array[4] of Text;
        Staff: Record Staff;
        CustomerRec: Record Customer;
        TransType: Text;
        dim: Record Dimension;



    begin


        if (Transaction."To Account")
        then begin
            TransType := 'مبيعات آجلة'
        end else begin

            TransType := 'مبيعات نقدية'
        end;




        CustomerRec.SetFilter("No.", Transaction."Customer No.");

        CustomerRec.FindFirst();


        //LS-12346+
        IF Tray = 2 THEN
            blankStr := sender.StringPad(' ', LineLen - 38)
        ELSE
            IF Tray = 4 THEN
                blankStr := sender.StringPad(' ', InvLineLen - 38);

        IF blankStr = '' THEN
            blankStr := ' ';

        //EDMABODON_20201104: Add Header ++
        // DSTR1 := '#C################################################';
        // Value[1] := '';
        // sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        // sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201104: Add Header --

        CLEAR(Value);
        //  DSTR1 := '#R#####################' + blankStr + '#R#############';
        //  Value[1] := Transaction."Receipt No.";
        //   NodeName[1] := 'Receipt No.';
        //   NodeName[1] := 'رقم الإيصال';
        //   Value[2] := 'رقم الإيصال';
        //   NodeName[2] := 'x';

        //  sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        //  sender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        StaffName := Transaction."Staff ID";
        IF Staff.GET(Transaction."Staff ID") THEN
            StaffName := Staff."Name on Receipt";

        CLEAR(Value);
        DSTR1 := '#R########## #R########' + blankStr + '#R#############';
        Value[1] := FORMAT(PrTime, 0, '<Hours12>:<Minutes,2>:<Seconds,2> <AM/PM>');
        NodeName[1] := 'Trans. Time';
        //Value[2] := FORMAT(PrDate);
        Value[2] := FORMAT(PrDate, 0, '<Day,2>/<Month,2>/<Year4>');
        NodeName[2] := 'Trans. Date';
        Value[3] := Text048 + ':';
        Value[3] := ':' + 'التاريخ';
        NodeName[3] := 'x';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 3, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        IF Transaction.Comment <> '' THEN BEGIN
            CLEAR(Value);
            DSTR1 := '#R########' + blankStr + '#R############';
            IF Transaction."Table No." <> 0 THEN
                Value[1] := Text500 + ':'
            ELSE
                Value[1] := Text367 + ':';
            NodeName[1] := 'x';
            Value[2] := FORMAT(Transaction.Comment);
            NodeName[2] := 'x';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            sender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        END;
        //sender.PrintSeperator(Tray);


        //EDMABODON_20201101: ++
        CLEAR(Value);
        DSTR1 := '#R##################' + blankStr + '#R################';
        Value[2] := 'المحاسب';
        NodeName[2] := 'x';
        //Value[1] := StaffName;
        Value[1] := Transaction."Staff ID";
        NodeName[1] := 'x';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 2, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201101: --
        //EDMABODON_20201001: Add Terminal ++
        DSTR1 := '#R##################' + blankStr + '#R################';
        Value[1] := Transaction."POS Terminal No.";
        Value[2] := 'الكاونتر';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201001: Add Terminal --


        //EDMABODON_20201001: Add Customer ++
        DSTR1 := '#R##################' + blankStr + '#R################';
        if dim.Get(Transaction."Global Dimension 2 Code") then
            Value[1] := dim.Description
        else
            Value[1] := Transaction."Global Dimension 2 Code";

        Value[2] := ':' + 'القسم';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
        sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, TRUE, FALSE, FALSE, Tray);
        //EDMABODON_20201001: Add Customer --


        sender.PrintSeperator(Tray);
    end;



    procedure PrintSalesInfo(VAR Transaction: Record "Transaction Header"; Tray: Integer; GenPosFunc: Record "POS Functionality Profile";
        sender: Codeunit "POS Print Utility"; IsInvoice: Boolean; bSecondPrintActive: Boolean; LineLen: Integer)

    var
        StringLenBeforeSplitLine: Integer;
        TransInfoCode: Record "Trans. Infocode Entry";
        Customer: Record Customer;
        DSTR1: Text;
        Value: array[10] of Text;
        NodeName: array[10] of Text;
        Contact: Record Contact;
        PerDiscOffArrCount: Integer;
        totalCustItemDisc: Integer;
        TotalNumberOfItems: Integer;
        TotalSavings: Integer;
        LineCount: Integer;
        VATCode: array[10] of Code[10];
        TotalAmt: Decimal;
        TipsAmount1: Decimal;
        TipsText1: Text;
        TipsAmount2: Decimal;
        TipsText2: Text;
        glTrans: Record "Transaction Header";
        ParentItemLine: Record "Trans. Sales Entry";
        SalesEntry: Record "Trans. Sales Entry";
        SalesEntry2: Record "Trans. Sales Entry";
        CompressItemOK: Boolean;
        CountItemOk: Boolean;
        LastDepartment: Text;
        PrintItemNo: Integer;

        Subtotal: Decimal;
        OrderByDepartment: Boolean;
        POSTerminal: Record "POS Terminal";
        Item: Record Item;
        ParentItem: Record Item;
        LinkedItems: Record "Linked Item";
        NegativeQty: Integer;
        LastQuantity: Integer;
        VATNotSet: Boolean;
        VATPostingSetup: Record "VAT Posting Setup";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        lUOM: Record "Unit of Measure";
        DiscountOnLine: Decimal;
        i: Integer;
        j: Integer;
        POSFunctions: Codeunit "POS Functions";
        SalesLineAmount: Decimal;
        Store: Record Store;
        ItemName: Text;
        PeriodicDiscountInfoTEMP: Record "Periodic Discount" TEMPORARY;
        RecipeBufferTEMP: Record "Trans. Sales Entry" TEMPORARY;
        //   RecipeBufferTransInfoTEMP: Record "Trans. Sales Entry";
        // RecipeBufferDetailTEMP_l: Record "Trans. Sales Entry";
        RecipeBufferTEMP2: Record "Trans. Sales Entry" temporary;
        RecipeBufferTransInfoTextTEMP: Record "Trans. Infocode Entry" TEMPORARY;
        RecipeBufferTransInfoTEMP: Record "Trans. Infocode Entry" TEMPORARY;
        RecipeBufferDetailTEMP_l: Record "Trans. Discount Entry" TEMPORARY;
        ItemSoldUOMFactor: Decimal;
        TmpValue: Text;
        IncExpEntry: Record "Trans. Income/Expense Entry";
        DSTR2: Text;
        lItemName2: Text;
        DiscountText: Text;
        CouponHeader: Record "Coupon Header";
        PeriodicDiscount: Record "Periodic Discount";
        TransInfoEntry: Record "Trans. Infocode Entry";
        IncExpAcc: Record "Income/Expense Account";
        IncomeExpenseAccount: Record "Income/Expense Account";
        ThisIsAHospTipsLine: Boolean;
        PaymEntry: Record "Trans. Payment Entry";
        TenderType: Record "Tender Type";
        TransInfocodeEntry: Record "Trans. Infocode Entry";
        lPOSCardEntry: Record "POS Card Entry";
        MixMatchEntry: Record "Trans. Mix & Match Entry";
        TenderTypeCardSetup: Record "Tender Type Card Setup";
        PosSetup: Record "POS Hardware Profile";
        TipsStaff_l: Record Staff;
        discountSection: Boolean;
        lTotalAmountTendered: Decimal;
        VATSetup: Record "POS VAT Code";
        VATPerc: array[15] of Decimal;
        VATAmount: array[15] of Decimal;
        SalesAmountVAT: array[15] of Decimal;
        VATPrinted: Boolean;
        lNetAmount: Decimal;
        maxCounter: Integer;
        lVATAmount: Decimal;
        lAmount: Decimal;
        HospitalityType: Record "Hospitality Type";
        Currency: Record Currency;
        PerDiscOffArr: array[10] of Code[23];
        PerDiscOffAmtArr: array[10] of Decimal;
        VendorTotal: Decimal;

    begin

        //PrintSalesInfo


        StringLenBeforeSplitLine := 11;

        IF GenPosFunc."Multiple Items Symbol" = '' THEN
            GenPosFunc."Multiple Items Symbol" := ' x ';

        TransInfoCode.SETRANGE("Store No.", Transaction."Store No.");
        TransInfoCode.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
        TransInfoCode.SETRANGE("Transaction No.", Transaction."Transaction No.");
        TransInfoCode.SETRANGE("Transaction Type", TransInfoCode."Transaction Type"::Header);
        if (TransInfoCode.FindFirst())
        then begin
            sender.PrintTransInfoCode(TransInfoCode, Tray, TRUE);
        end;


        CLEAR(Customer);

        DSTR1 := '#T######################################';

        IF Transaction."Customer No." <> '' THEN BEGIN
            IF Transaction."Post as Shipment" THEN BEGIN
                Value[1] := '';
                NodeName[1] := 'Print Info';
                sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, '#C##################'), TRUE, TRUE, TRUE, FALSE));
                sender.AddPrintLine(250, 1, NodeName, Value, '#C##################', TRUE, TRUE, TRUE, FALSE, Tray);
                sender.PrintLine(Tray, '');
            END;
            IF Customer.GET(Transaction."Customer No.") THEN BEGIN
                Value[1] := COPYSTR(Customer."No." + ' ' + Customer.Name, 1, MAXSTRLEN(Value[1]));
                NodeName[1] := 'x';
                Value[2] := Customer."No.";
                NodeName[2] := 'Customer No.';
                Value[3] := Customer.Name;
                NodeName[3] := 'Customer Name';
                sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                sender.AddPrintLine(200, 3, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                sender.PrintSeperator(Tray);
            END;
        END;
        IF Transaction."Sell-to Contact No." <> '' THEN BEGIN
            IF Contact.GET(Transaction."Sell-to Contact No.") THEN BEGIN
                Value[1] := COPYSTR(Contact."No." + ' ' + Contact.Name, 1, MAXSTRLEN(Value[1]));
                NodeName[1] := 'x';
                Value[2] := Contact."No.";
                NodeName[2] := 'Contact No.';
                Value[3] := Contact.Name;
                NodeName[3] := 'Contact Name';
                sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                sender.AddPrintLine(200, 3, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                sender.PrintSeperator(Tray);
            END;
        END;
        IF Transaction."Sale Is Return Sale" THEN BEGIN
            Value[1] := '';
            NodeName[1] := 'Description';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, '#C##################'), TRUE, TRUE, TRUE, FALSE));
            sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
            sender.PrintSeperator(Tray);
        END;


        IF NOT IsInvoice THEN BEGIN
            IF Transaction.GetPrintedCounter(1) > 0 THEN
                sender.PrintCopyText(Tray)
            ELSE
                IF bSecondPrintActive THEN BEGIN
                    DSTR1 := '#C##################';
                    Value[1] := '';
                    DSTR1 := '#C' + sender.StringPad('#', LineLen - 2);
                    Value[1] := sender.StringPad('-', LineLen);
                END;
        END;

        IF Transaction."Entry Status" = Transaction."Entry Status"::Training THEN
            sender.PrintTrainingText(Tray);

        PerDiscOffArrCount := 0;
        totalCustItemDisc := 0;

        CLEAR(TotalNumberOfItems);
        CLEAR(TotalSavings);

        LineCount := 0;
        CLEAR(VATCode);
        CLEAR(VATPerc);
        CLEAR(VATAmount);
        CLEAR(SalesAmountVAT);
        CLEAR(SalesEntry);
        CLEAR(Value);
        //  tmpDeal.DELETEALL;
        //  TmpPrintedSalesEntry.DELETEALL;
        //  TmpPrintedDealPOSTransLine.DELETEALL;
        IF GenPosFunc."Print Disc/Cpn Info on Slip" IN
         [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
          GenPosFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total"] THEN BEGIN
            PeriodicDiscountInfoTEMP.RESET;
            PeriodicDiscountInfoTEMP.DELETEALL;
            Subtotal := 0;
        END;
        TotalAmt := 0;
        TipsAmount1 := 0;
        TipsText1 := '';
        TipsAmount2 := 0;
        TipsText2 := '';
        glTrans := Transaction;
        SalesEntry.SETRANGE("Store No.", Transaction."Store No.");
        SalesEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
        SalesEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
        OrderByDepartment := GenPosFunc."Receipt Printing by Category";
        IF OrderByDepartment THEN
            SalesEntry.SETCURRENTKEY("Item Category Code");
        IF SalesEntry.FIND('-') THEN BEGIN
            IF GenPosFunc."Print Free Text on Receipt" THEN BEGIN
                sender.PrintFreeTextLinesBeginning(SalesEntry, Tray, FALSE);
            END;
            DSTR1 := '#L############### #R############## #R##   ';
            //Print Receipt Header
            //EDMABODON_20201004 

            Value[3] := 'م';
            Value[2] := 'اسم الصنف';
            Value[1] := 'الوحدة';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            // sender.PrintSeperator(Tray);

            //EDMABODON_20201004 ++
            //DSTR1 := '#L#######   #N########  #R#######  ##########   ';
            //DSTR1 := '#L#### #T###### #T###' + blankStr + '#L### #N#########';
            DSTR1 := '#R######## #R###### #R######## #R########';
            Value[4] := 'الكمية';
            Value[3] := 'السعر';
            Value[2] := 'ضريبة';
            Value[1] := 'المجموع';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            sender.AddPrintLine(300, 4, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
            sender.PrintSeperator(Tray);
            //EDMABODON_20201004 --



            PrintItemNo := 0;
            IF POSTerminal.GET(SalesEntry."POS Terminal No.") THEN
                IF POSTerminal."Receipt Setup Location" = POSTerminal."Receipt Setup Location"::Store THEN BEGIN
                    CASE Store."Item No. on Receipt" OF
                        Store."Item No. on Receipt"::"Item Number":
                            PrintItemNo := 1;
                        Store."Item No. on Receipt"::"Barcode/Item Number":
                            PrintItemNo := 2;
                    END;
                END ELSE BEGIN
                    CASE POSTerminal."Item No. on Receipt" OF
                        POSTerminal."Item No. on Receipt"::"Item Number":
                            PrintItemNo := 1;
                        POSTerminal."Item No. on Receipt"::"Barcode/Item Number":
                            PrintItemNo := 2;
                    END;
                END;

            LastDepartment := '';
            RecipeBufferTEMP.RESET;
            RecipeBufferTEMP.DELETEALL;
            RecipeBufferDetailTEMP_l.RESET;
            RecipeBufferDetailTEMP_l.DELETEALL;
            RecipeBufferTEMP2.RESET;
            RecipeBufferTEMP2.DELETEALL;
            RecipeBufferTransInfoTEMP.RESET;
            RecipeBufferTransInfoTEMP.DELETEALL;
            RecipeBufferTransInfoTextTEMP.RESET;
            RecipeBufferTransInfoTextTEMP.DELETEALL;
            REPEAT
                CLEAR(Item);
                IF Item.GET(SalesEntry."Item No.") THEN;

                IF SalesEntry."Parent Line No." = 0 THEN BEGIN
                    ParentItem := Item;
                    ParentItemLine := SalesEntry;
                END;

                //All lines except deal lines are put into recipe-item buffer. For cases where lines must not be compressed, CompresItemOK is set as false
                CompressItemOK := TRUE;
                IF ParentItem."Skip Compression When Printed" THEN
                    CompressItemOK := FALSE;
                IF NOT (SalesEntry."Orig. from Infocode" <> '') AND (SalesEntry."Parent Line No." <> 0) THEN BEGIN
                    IF SalesEntry."Price Change" THEN
                        CompressItemOK := FALSE;
                    IF SalesEntry."Scale Item" THEN
                        CompressItemOK := FALSE;
                    IF SalesEntry."Price in Barcode" THEN
                        CompressItemOK := FALSE;
                    IF SalesEntry.Quantity > 0 THEN BEGIN
                        CompressItemOK := FALSE;
                        NegativeQty += 1;
                    END;
                    IF LastQuantity = 0 THEN
                        LastQuantity := SalesEntry.Quantity;
                    IF (LastQuantity <> 0) AND ((LastQuantity < 0) OR (SalesEntry.Quantity < 0)) AND (NegativeQty <> 0) THEN BEGIN
                        CompressItemOK := FALSE;
                        LastQuantity := 0;
                    END;
                END;
                IF (NOT SalesEntry."Deal Line") THEN
                    sender.InsertIntoRecipeBuffer(
                        SalesEntry, RecipeBufferTEMP, RecipeBufferTEMP2, ParentItemLine, RecipeBufferDetailTEMP_l,
                        RecipeBufferTransInfoTEMP, RecipeBufferTransInfoTextTEMP, CompressItemOK);

                IF POSTerminal."Print Total Savings" THEN BEGIN
                    TotalSavings := TotalSavings + SalesEntry."Discount Amount";
                END;

                IF POSTerminal."Print Number of Items" THEN BEGIN
                    IF (SalesEntry.Quantity < 0) THEN BEGIN
                        CountItemOk := TRUE;
                        IF SalesEntry."Linked No. not Orig." THEN BEGIN
                            SalesEntry2.RESET;
                            SalesEntry2.COPYFILTERS(SalesEntry);
                            IF SalesEntry2.FIND('-') THEN BEGIN
                                REPEAT
                                    IF (SalesEntry2."Item No." <> SalesEntry."Item No.") AND SalesEntry2."Orig. of a Linked Item List" THEN BEGIN
                                        LinkedItems.RESET;
                                        LinkedItems.SETRANGE("Item No.", SalesEntry2."Item No.");
                                        LinkedItems.SETRANGE("Linked Item No.", SalesEntry."Item No.");
                                        LinkedItems.SETFILTER("Sales Type", '%1|%2', '', Transaction."Sales Type");
                                        IF LinkedItems.FINDFIRST THEN BEGIN
                                            IF LinkedItems."Deposit Item" THEN
                                                CountItemOk := FALSE;
                                        END;
                                    END;
                                UNTIL (SalesEntry2.NEXT = 0) OR NOT CountItemOk;
                            END;
                        END;

                        IF CountItemOk THEN BEGIN
                            IF ItemUnitOfMeasure.GET(SalesEntry."Item No.", SalesEntry."Unit of Measure") THEN BEGIN
                                IF ItemUnitOfMeasure."Count as 1 on Receipt" THEN
                                    TotalNumberOfItems := TotalNumberOfItems + 1
                                ELSE
                                    TotalNumberOfItems := TotalNumberOfItems + ABS(SalesEntry.Quantity);
                            END ELSE
                                TotalNumberOfItems := TotalNumberOfItems + ABS(SalesEntry.Quantity);
                        END;

                    END;
                END;

                IF SalesEntry."Deal Line" THEN BEGIN
                    sender.PrintDeal(SalesEntry, Tray, PrintItemNo);
                    sender.CollectDiscInfo(SalesEntry, Tray, TotalAmt, Subtotal, PeriodicDiscountInfoTEMP);
                    IF GenPosFunc."Print Disc/Cpn Info on Slip" =
                      GenPosFunc."Print Disc/Cpn Info on Slip"::"No printing"
                    THEN
                        SalesLineAmount := SalesEntry."Net Amount" + SalesEntry."VAT Amount"
                    ELSE
                        SalesLineAmount :=
                          SalesEntry."Net Amount" + SalesEntry."VAT Amount"
                          - SalesEntry."Discount Amount";
                    IF GenPosFunc."Print Disc/Cpn Info on Slip" =
                        GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line"
                    THEN
                        TotalAmt := TotalAmt + SalesLineAmount
                    ELSE
                        IF GenPosFunc."Print Disc/Cpn Info on Slip" =
                          GenPosFunc."Print Disc/Cpn Info on Slip"::"No printing"
                        THEN
                            TotalAmt := TotalAmt + SalesLineAmount;
                    //*************** normal line, not deal line printed with recipe-item buffer
                END ELSE BEGIN
                    sender.CollectDiscInfo(SalesEntry, Tray, TotalAmt, Subtotal, PeriodicDiscountInfoTEMP);
                END;

                totalCustItemDisc := totalCustItemDisc + SalesEntry."Infocode Discount";

                i := 0;
                j := 0;
                VATNotSet := TRUE;
                IF SalesEntry."Net Amount" > 0 THEN
                    IF Item.GET(SalesEntry."Item No.") THEN
                        IF VATPostingSetup.GET(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") THEN
                            IF VATSetup.GET(VATPostingSetup."POS Terminal VAT Code") THEN
                                VATNotSet := FALSE;
                IF VATNotSet THEN
                    IF VATSetup.GET(SalesEntry."VAT Code") THEN
                        VATNotSet := FALSE;
                IF (VATSetup."VAT Code" <> '') AND NOT VATNotSet THEN BEGIN
                    REPEAT
                        i := i + 1;
                        IF j = 0 THEN
                            IF VATCode[i] = '' THEN
                                j := i;
                    UNTIL (VATCode[i] = VATSetup."VAT Code") OR (i >= 5);
                    IF VATCode[i] <> VATSetup."VAT Code" THEN BEGIN
                        i := j;
                        VATPerc[i] := VATSetup."VAT %";
                        VATCode[i] := VATSetup."VAT Code";
                    END;
                    VATAmount[i] := VATAmount[i] + SalesEntry."VAT Amount";
                    //  gVATAmount := gVATAmount + VATAmount[i];
                    SalesAmountVAT[i] := SalesAmountVAT[i] + SalesEntry."Net Amount" + SalesEntry."VAT Amount";
                END;
                LineCount := LineCount + 1;
            UNTIL SalesEntry.NEXT = 0;
        END;

        RecipeBufferTEMP.RESET;
        RecipeBufferTEMP2.RESET;
        RecipeBufferTEMP.SETRANGE("Parent Line No.", 0);
        IF OrderByDepartment THEN
            RecipeBufferTEMP.SETCURRENTKEY("Item Category Code");
        IF RecipeBufferTEMP.FIND('-') THEN
            REPEAT
                IF OrderByDepartment AND (RecipeBufferTEMP."Item Category Code" <> LastDepartment) THEN BEGIN
                    DSTR1 := '#L######################################';
                    Value[1] := RecipeBufferTEMP."Item Category Code";
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                    LastDepartment := RecipeBufferTEMP."Item Category Code";
                END;

                DiscountOnLine := 0;
                IF GenPosFunc."Print Disc/Cpn Info on Slip" IN
                  [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line",
                   GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                   GenPosFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total"] THEN BEGIN
                    // DiscountOnLine := -RecipeBufferTEMP."Discount Amount";
                END;

                ItemName := GetItemName(RecipeBufferTEMP."Item No.", RecipeBufferTEMP."Variant Code", Customer."Language Code", Store."Language Code");

                DSTR1 := '#L######### #L###################';
                IF PrintItemNo <> 0 THEN BEGIN
                    IF PrintItemNo = 1 THEN BEGIN
                        Value[1] := 'Text074';
                        NodeName[1] := 'x';
                        Value[2] := RecipeBufferTEMP."Item No.";
                        NodeName[2] := 'Item No.';
                    END
                    ELSE BEGIN
                        IF RecipeBufferTEMP."Barcode No." <> '' THEN BEGIN
                            Value[1] := 'Text075';
                            NodeName[1] := 'x';
                            Value[2] := RecipeBufferTEMP."Barcode No.";
                            NodeName[2] := 'Barcode';
                        END
                        ELSE BEGIN
                            Value[1] := 'Text074';
                            NodeName[1] := 'x';
                            Value[2] := RecipeBufferTEMP."Item No.";
                            NodeName[2] := 'Item No.';
                        END;
                    END;
                    Value[3] := FORMAT(RecipeBufferTEMP."Line No.");
                    NodeName[3] := 'Line No.';
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    sender.AddPrintLine(300, 3, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                END;


                IF (ABS(RecipeBufferTEMP.Quantity) <> 1) OR
                   ((RecipeBufferTEMP."UOM Quantity" <> 0) AND (ABS(RecipeBufferTEMP."UOM Quantity") <> 1)) OR
                   RecipeBufferTEMP."Scale Item" OR               //details always printed.
                   RecipeBufferTEMP."Price in Barcode"
                THEN BEGIN
                    //EDMSTOP

                    //DSTR1 := '#L## #L###### #R############################';
                    DSTR1 := '#L### #R########################## #R#';
                    // EDMABODON_20201202: Print Arabic UOM ++
                    //Value[2] := RecipeBufferTEMP."Unit of Measure";
                    CLEAR(lUOM);
                    IF lUOM.GET(RecipeBufferTEMP."Unit of Measure") THEN
                        Value[1] := lUOM."Description Arabic";
                    // EDMABODON_20201202: Print Arabic UOM --
                    NodeName[1] := 'UOM ID';
                    IF STRLEN(ItemName) > 30 THEN BEGIN
                        Value[2] := COPYSTR(ItemName, 1, 30);
                    END ELSE
                        Value[2] := ItemName;
                    NodeName[2] := 'Item Description';
                    Value[3] := FORMAT(RecipeBufferTEMP."POS Trans. Line No.");
                    NodeName[3] := 'LineNO';
                    Value[4] := FORMAT(RecipeBufferTEMP."POS Trans. Line No.");
                    NodeName[4] := 'Line No.';
                    Value[5] := RecipeBufferTEMP."Item No.";
                    NodeName[5] := 'Item No.';
                    Value[6] := RecipeBufferTEMP."Variant Code";
                    NodeName[6] := 'Variant Code';
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    sender.AddPrintLine(300, 4, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);

                    CLEAR(Value);
                    DSTR1 := '   #L################### #N########## #R';
                    IF RecipeBufferTEMP."Scale Item" OR RecipeBufferTEMP."Price in Barcode" THEN BEGIN
                        IF RecipeBufferTEMP."Weight Manually Entered" THEN
                            DSTR1 := 'MAN #L################## #N########## #R';
                        Value[1] :=
                          Value[1] + POSFunctions.FormatWeight(-RecipeBufferTEMP.Quantity, RecipeBufferTEMP."Unit of Measure") +
                          ' ' + GenPosFunc."Multiple Items Symbol" + ' ';
                        TmpValue := POSFunctions.FormatPricePrUnit(RecipeBufferTEMP.Price, RecipeBufferTEMP."Unit of Measure");
                        IF Item.GET(RecipeBufferTEMP."Item No.") THEN
                            IF RecipeBufferTEMP."Unit of Measure" <> Item."Base Unit of Measure" THEN BEGIN
                                ItemSoldUOMFactor := 0;
                                IF ItemUnitOfMeasure.GET(RecipeBufferTEMP."Item No.", RecipeBufferTEMP."Unit of Measure") THEN
                                    ItemSoldUOMFactor := ItemUnitOfMeasure."Qty. per Unit of Measure";
                                IF (ItemSoldUOMFactor <> 1) AND (ItemSoldUOMFactor <> 0) THEN BEGIN
                                    Value[1] := POSFunctions.FormatWeight(-RecipeBufferTEMP.Quantity / ItemSoldUOMFactor, RecipeBufferTEMP."Unit of Measure") +
                                      ' ' + GenPosFunc."Multiple Items Symbol" + ' ';
                                    TmpValue := POSFunctions.FormatPricePrUnit(RecipeBufferTEMP.Price * ItemSoldUOMFactor, RecipeBufferTEMP."Unit of Measure");
                                END;
                            END;
                        IF STRLEN(TmpValue) > StringLenBeforeSplitLine THEN BEGIN
                            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0), FALSE, FALSE));
                            Value[1] := TmpValue;
                        END ELSE
                            Value[1] := Value[1] + TmpValue;
                    END ELSE BEGIN
                        IF RecipeBufferTEMP."Unit of Measure" = '' THEN
                            RecipeBufferTEMP."Unit of Measure" := 'Text131';
                        IF RecipeBufferTEMP."UOM Quantity" <> 0 THEN BEGIN
                            RecipeBufferTEMP.Quantity := RecipeBufferTEMP."UOM Quantity";
                            RecipeBufferTEMP.Price := RecipeBufferTEMP."UOM Price";
                        END;
                        Value[1] :=
                          POSFunctions.FormatQty(-RecipeBufferTEMP.Quantity) + ' ' + LOWERCASE(RecipeBufferTEMP."Unit of Measure") +
                          ' ' + GenPosFunc."Multiple Items Symbol" + ' ';
                        Value[1] := Value[1] + POSFunctions.FormatPrice(RecipeBufferTEMP.Price);
                    END;
                    //DSTR1 := '#L####### #N##### #N############## #R##   ';
                    DSTR1 := '#L######## #N###### #N######## #R########';
                    Value[1] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + RecipeBufferTEMP."VAT Amount" + DiscountOnLine));
                    NodeName[1] := 'Amount';
                    Value[2] := FORMAT(-RecipeBufferTEMP."VAT Amount");
                    NodeName[2] := 'VAT Amount';
                    Value[3] := POSFunctions.FormatPrice(RecipeBufferTEMP.Price);
                    //Value[3] := POSFunctions.FormatPrice(RecipeBufferTEMP."Net Price");  //As per Al Amer Market decision 20210211 Abou zakaria to remove it
                    NodeName[3] := 'Price';
                    Value[4] := POSFunctions.FormatQty(-RecipeBufferTEMP.Quantity);
                    NodeName[4] := 'Quantity';
                    Value[5] := RecipeBufferTEMP."VAT Code";
                    NodeName[5] := 'VAT Code';
                    Value[6] := FORMAT(RecipeBufferTEMP."Line No.");
                    NodeName[6] := 'Line No.';
                    // EDMABODON_20201202: Print Arabic UOM ++
                    //Value[5] := RecipeBufferTEMP."Unit of Measure";
                    CLEAR(lUOM);
                    IF lUOM.GET(RecipeBufferTEMP."Unit of Measure") THEN
                        Value[5] := lUOM."Description Arabic";
                    // EDMABODON_20201202: Print Arabic UOM --
                    NodeName[5] := 'UOM ID';

                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0) or (RecipeBufferTEMP."Promotion No." <> ''), FALSE, FALSE));
                    sender.AddPrintLine(300, 7, NodeName, Value, DSTR1, FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0) or (RecipeBufferTEMP."Promotion No." <> ''), FALSE, FALSE, Tray);
                    PrintSeperator(Tray, sender);
                END
                ELSE BEGIN //EDMABODON Print Item lines

                    DSTR1 := '#L### #R########################## #R#';
                    // EDMABODON_20201202: Print Arabic UOM ++
                    Value[1] := LOWERCASE(RecipeBufferTEMP."Unit of Measure");
                    CLEAR(lUOM);
                    IF lUOM.GET(RecipeBufferTEMP."Unit of Measure") THEN
                        Value[1] := lUOM."Description Arabic";
                    // EDMABODON_20201202: Print Arabic UOM --
                    NodeName[1] := 'Unit of Measure';
                    IF STRLEN(ItemName) > 30 THEN BEGIN
                        Value[2] := COPYSTR(ItemName, 1, 30);
                    END ELSE
                        Value[2] := ItemName;
                    NodeName[2] := 'Item Description';
                    Value[3] := FORMAT(RecipeBufferTEMP."POS Trans. Line No.");
                    NodeName[3] := 'LineNO';
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0) or (RecipeBufferTEMP."Promotion No." <> ''), FALSE, FALSE));
                    sender.AddPrintLine(300, 1, NodeName, Value, DSTR1, FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0) or (RecipeBufferTEMP."Promotion No." <> ''), FALSE, FALSE, Tray);
                    //EDMABODON Item Description on two rows ++
                    lItemName2 := COPYSTR(ItemName, 31, 41);
                    IF STRLEN(lItemName2) > 0 THEN BEGIN
                        CLEAR(Value);
                        Value[1] := lItemName2;
                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    END;
                    //EDMABODON
                    //DSTR1 := '#L###################### #N########## #R';
                    DSTR1 := '#L######## #N###### #N######## #R########';
                    CLEAR(Value);
                    CLEAR(NodeName);
                    Value[1] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + RecipeBufferTEMP."VAT Amount" + DiscountOnLine));
                    NodeName[1] := 'Price';
                    Value[2] := FORMAT(-RecipeBufferTEMP."VAT Amount");
                    NodeName[2] := 'VAT Amount';
                    Value[3] := POSFunctions.FormatPrice(RecipeBufferTEMP.Price);
                    //Value[3] := POSFunctions.FormatPrice(RecipeBufferTEMP."Net Price"); // As Per Al Amer Market Decision 20210211 Abou Zakaria remove it
                    NodeName[3] := 'Price';
                    Value[4] := POSFunctions.FormatQty(-RecipeBufferTEMP.Quantity);
                    NodeName[4] := 'Quantity';

                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0) or (RecipeBufferTEMP."Promotion No." <> ''), FALSE, FALSE));
                    sender.AddPrintLine(300, 4, NodeName, Value, DSTR1, FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0) or (RecipeBufferTEMP."Promotion No." <> ''), FALSE, FALSE, Tray);
                    PrintSeperator(Tray, sender);
                END;
                IF GenPosFunc."Print Free Text on Receipt" THEN
                    sender.PrintFreeTextLinesFromBuffer(RecipeBufferTEMP, RecipeBufferTransInfoTextTEMP, Tray, FALSE);
                //TODO
                // sender.PrintItemPOSText(RecipeBufferTEMP."Item No.",Customer."Language Code",Store."Language Code",RecipeBufferTEMP."Line No.",Tray);

                RecipeBufferTransInfoTEMP.SETRANGE("Store No.", Transaction."Store No.");
                RecipeBufferTransInfoTEMP.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
                RecipeBufferTransInfoTEMP.SETRANGE("Transaction No.", Transaction."Transaction No.");
                RecipeBufferTransInfoTEMP.SETRANGE("Transaction Type", RecipeBufferTransInfoTEMP."Transaction Type"::"Sales Entry");
                RecipeBufferTransInfoTEMP.SETRANGE("Line No.", RecipeBufferTEMP."Line No.");
                sender.PrintTransInfoCode(RecipeBufferTransInfoTEMP, Tray, FALSE);

                IF GenPosFunc."Print Disc/Cpn Info on Slip" IN
                  [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                  GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line"]
                THEN BEGIN
                    RecipeBufferDetailTEMP_l.RESET;
                    RecipeBufferDetailTEMP_l.SETRANGE("Store No.", RecipeBufferTEMP."Store No.");
                    RecipeBufferDetailTEMP_l.SETRANGE("POS Terminal No.", RecipeBufferTEMP."POS Terminal No.");
                    RecipeBufferDetailTEMP_l.SETRANGE("Transaction No.", RecipeBufferTEMP."Transaction No.");
                    RecipeBufferDetailTEMP_l.SETRANGE(RecipeLineNo, RecipeBufferTEMP."Line No.");
                    IF RecipeBufferDetailTEMP_l.FINDSET THEN
                        REPEAT
                            IF RecipeBufferDetailTEMP_l."Offer Type" = RecipeBufferDetailTEMP_l."Offer Type"::Line THEN
                                DiscountText := 'Text084'
                            ELSE
                                DiscountText := FORMAT(RecipeBufferDetailTEMP_l."Offer Type");
                            CLEAR(PeriodicDiscount);
                            IF RecipeBufferDetailTEMP_l."Offer Type" = RecipeBufferDetailTEMP_l."Offer Type"::Coupon THEN BEGIN
                                IF CouponHeader.GET(RecipeBufferDetailTEMP_l."Offer No.") THEN
                                    DiscountText := CouponHeader.Description;
                            END ELSE
                                IF PeriodicDiscount.GET(RecipeBufferDetailTEMP_l."Offer No.") THEN
                                    DiscountText := PeriodicDiscount.Description
                                ELSE
                                    CASE RecipeBufferDetailTEMP_l."Offer Type" OF
                                        RecipeBufferDetailTEMP_l."Offer Type"::Total:
                                            DiscountText := 'Text024';
                                        RecipeBufferDetailTEMP_l."Offer Type"::Line:
                                            DiscountText := 'Text084';
                                        ELSE
                                            DiscountText := FORMAT(RecipeBufferDetailTEMP_l."Offer Type");
                                    END;
                            DiscountText := CONVERTSTR(DiscountText, '&', '+');
                            IF NOT PeriodicDiscount."Block Printing" THEN BEGIN
                                IF NOT RecipeBufferTEMP."Deal Line" THEN BEGIN
                                    IF RecipeBufferDetailTEMP_l."Discount Amount" <> 0 THEN BEGIN
                                        IF NOT ((RecipeBufferDetailTEMP_l."Offer Type" = RecipeBufferDetailTEMP_l."Offer Type"::Total) AND
                                          (GenPosFunc."Print Disc/Cpn Info on Slip" =
                                          GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total")) THEN BEGIN
                                            DSTR2 := '   #L################# #N############   ';
                                            Value[1] := DiscountText;
                                            NodeName[1] := 'Detail Text';
                                            Value[2] := POSFunctions.FormatAmount(-RecipeBufferDetailTEMP_l."Discount Amount");
                                            NodeName[2] := 'Detail Amount';
                                            Value[3] := FORMAT(RecipeBufferTEMP."Line No.");
                                            NodeName[3] := 'Line No.';
                                            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR2), FALSE, FALSE, FALSE, FALSE));
                                            sender.AddPrintLine(360, 3, NodeName, Value, DSTR2, FALSE, FALSE, FALSE, FALSE, Tray);
                                        END;
                                    END;
                                    IF RecipeBufferDetailTEMP_l.Points <> 0 THEN BEGIN
                                        DSTR2 := '   #L################# #N############   ';
                                        Value[1] := DiscountText;
                                        NodeName[1] := 'Detail Text';
                                        Value[2] := POSFunctions.FormatAmount(RecipeBufferDetailTEMP_l.Points) + ' ' + 'Text232';
                                        NodeName[2] := 'x';
                                        Value[3] := FORMAT(RecipeBufferTEMP."Line No.");
                                        NodeName[3] := 'Line No.';
                                        Value[4] := POSFunctions.FormatAmount(RecipeBufferDetailTEMP_l.Points);
                                        NodeName[4] := 'Detail Amount';
                                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR2), FALSE, FALSE, FALSE, FALSE));
                                        sender.AddPrintLine(360, 4, NodeName, Value, DSTR2, FALSE, FALSE, FALSE, FALSE, Tray);
                                    END;
                                END;
                            END;
                        UNTIL RecipeBufferDetailTEMP_l.NEXT = 0;
                END;

                RecipeBufferTEMP2.SETRANGE("Parent Line No.", RecipeBufferTEMP."Line No.");
                IF RecipeBufferTEMP2.FINDSET THEN
                    REPEAT
                        ItemName := GetItemName(RecipeBufferTEMP2."Item No.", RecipeBufferTEMP2."Variant Code", Customer."Language Code", Store."Language Code");


                        DSTR1 := '#L######################################';
                        Value[1] := ItemName;
                        NodeName[1] := 'Item Description';
                        Value[2] := FORMAT(RecipeBufferTEMP2."Line No.");
                        NodeName[2] := 'Line No.';
                        Value[3] := RecipeBufferTEMP2."Item No.";
                        NodeName[3] := 'Item No.';
                        Value[4] := RecipeBufferTEMP2."Variant Code";
                        NodeName[4] := 'Variant Code';
                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                        sender.AddPrintLine(300, 4, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                        IF RecipeBufferTEMP2."Unit of Measure" = '' THEN
                            RecipeBufferTEMP2."Unit of Measure" := '¥ 젧';//Text131;
                        IF RecipeBufferTEMP2."UOM Quantity" <> 0 THEN BEGIN
                            RecipeBufferTEMP2.Quantity := RecipeBufferTEMP2."UOM Quantity";
                            RecipeBufferTEMP2.Price := RecipeBufferTEMP2."UOM Price";
                        END;
                        DSTR1 := '#L###################### #N########## #R';
                        Value[1] :=
                          POSFunctions.FormatQty(-RecipeBufferTEMP2.Quantity) + ' ' + LOWERCASE(RecipeBufferTEMP2."Unit of Measure") +
                          ' ' + GenPosFunc."Multiple Items Symbol" + ' ';
                        Value[1] := Value[1] + POSFunctions.FormatPrice(RecipeBufferTEMP2.Price);
                        NodeName[1] := 'x';
                        Value[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP2."Net Amount" + RecipeBufferTEMP2."VAT Amount"));
                        NodeName[2] := 'Amount';
                        Value[3] := RecipeBufferTEMP2."VAT Code";
                        NodeName[3] := 'VAT Code';
                        Value[4] := FORMAT(RecipeBufferTEMP2."Line No.");
                        NodeName[4] := 'Line No.';
                        // EDMABODON_20201202: Print Arabic UOM ++
                        Value[5] := RecipeBufferTEMP."Unit of Measure";
                        CLEAR(lUOM);
                        IF lUOM.GET(RecipeBufferTEMP."Unit of Measure") THEN
                            Value[2] := lUOM."Description Arabic";
                        // EDMABODON_20201202: Print Arabic UOM --
                        NodeName[5] := 'UOM ID';
                        Value[6] := POSFunctions.FormatQty(-RecipeBufferTEMP2.Quantity);
                        NodeName[6] := 'Quantity';
                        Value[7] := POSFunctions.FormatPrice(RecipeBufferTEMP2.Price);
                        NodeName[7] := 'Price';
                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, (RecipeBufferTEMP2."Periodic Discount" <> 0), FALSE, FALSE));
                        sender.AddPrintLine(300, 7, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                    UNTIL RecipeBufferTEMP2.NEXT = 0;
            UNTIL RecipeBufferTEMP.NEXT = 0;

        //LS-11909 LineCount := LineCount + PrintSPOSalesInfo(Transaction, Tray);
        //  IF LineCount > 0 THEN
        //   sender.PrintSeperator(Tray);

        IF totalCustItemDisc <> 0 THEN BEGIN
            DSTR1 := '#L################# #R###############   ';
            Value[1] := 'Text086';
            NodeName[1] := 'Total Text';
            Value[2] := POSFunctions.FormatAmount(totalCustItemDisc);
            NodeName[2] := 'Total Amount';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            sender.AddPrintLine(600, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
        END;

        IF Transaction."Customer Discount" <> 0 THEN BEGIN
            DSTR1 := '#L################# #R###############   ';
            Value[1] := 'Text085';
            NodeName[1] := 'Total Text';
            Value[2] := POSFunctions.FormatAmount(-Transaction."Customer Discount");
            NodeName[2] := 'Total Amount';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            sender.AddPrintLine(600, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
        END;

        IF (totalCustItemDisc <> 0) OR (Transaction."Customer Discount" <> 0) THEN
            sender.PrintSeperator(Tray);

        IncExpEntry.SETRANGE("Store No.", Transaction."Store No.");
        IncExpEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
        IncExpEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
        IF IncExpEntry.FIND('-') THEN BEGIN
            REPEAT
                IncExpAcc.GET(IncExpEntry."Store No.", IncExpEntry."No.");
                IF (IncExpAcc."Gratuity Type" = IncExpAcc."Gratuity Type"::Tips) AND
                  (IncExpAcc."Account Type" = IncExpAcc."Account Type"::Expense)
                THEN BEGIN
                    IF NOT (TipsStaff_l.GET(IncExpEntry."Staff ID")) THEN
                        TipsStaff_l."Name on Receipt" := IncExpEntry."Staff ID";
                    IncExpAcc.Description :=
                      COPYSTR(IncExpAcc.Description + ' ' + TipsStaff_l."Name on Receipt", 1, MAXSTRLEN(IncExpAcc.Description));
                END;
                DSTR1 := '#L#################### #N############';
                Value[1] := IncExpAcc.Description;
                NodeName[1] := 'Inc./Exp. Description';
                Value[2] := POSFunctions.FormatAmount(-IncExpEntry.Amount);
                NodeName[2] := 'Amount';
                Value[3] := IncExpEntry."VAT Code";
                NodeName[3] := 'VAT Code';
                Value[4] := FORMAT(IncExpEntry."Line No.");
                NodeName[4] := 'Line No.';
                Value[5] := IncExpEntry."No.";
                NodeName[5] := 'Income/Expense No.';
                DSTR1 := '#L#################### #N############ #R';

                IF IncExpEntry."VAT Code" <> '' THEN BEGIN
                    i := 0;
                    j := 0;
                    IF VATSetup.GET(IncExpEntry."VAT Code") THEN BEGIN
                        REPEAT
                            i := i + 1;
                            IF j = 0 THEN
                                IF VATCode[i] = '' THEN
                                    j := i;
                        UNTIL (VATCode[i] = VATSetup."VAT Code") OR (i >= 5);
                        IF VATCode[i] <> VATSetup."VAT Code" THEN BEGIN
                            i := j;
                            VATPerc[i] := VATSetup."VAT %";
                            VATCode[i] := VATSetup."VAT Code";
                        END;
                        VATAmount[i] := VATAmount[i] + IncExpEntry."VAT Amount";
                        SalesAmountVAT[i] := SalesAmountVAT[i] + IncExpEntry.Amount;
                    END;
                END;

                TotalAmt := TotalAmt + IncExpEntry.Amount;
                Subtotal := Subtotal + IncExpEntry.Amount;

                ThisIsAHospTipsLine := FALSE;
                IF IncExpEntry."No." <> '' THEN BEGIN
                    IF IncExpEntry."No." = HospitalityType."Tips Income Acc. 1" THEN BEGIN
                        ThisIsAHospTipsLine := TRUE;
                        TipsAmount1 := TipsAmount1 + IncExpEntry.Amount;
                        IF TipsText1 = '' THEN BEGIN
                            IncomeExpenseAccount.RESET;
                            IncomeExpenseAccount.SETRANGE("Store No.", Transaction."Store No.");
                            IncomeExpenseAccount.SETRANGE("No.", IncExpEntry."No.");
                            IF IncomeExpenseAccount.FINDFIRST THEN
                                TipsText1 := IncomeExpenseAccount.Description
                            ELSE
                                TipsText1 := 'Text321';
                        END
                    END
                    ELSE
                        IF IncExpEntry."No." = HospitalityType."Tips Income Acc. 2" THEN BEGIN
                            ThisIsAHospTipsLine := TRUE;
                            TipsAmount2 := TipsAmount2 + IncExpEntry.Amount;
                            IF TipsText2 = '' THEN BEGIN
                                IncomeExpenseAccount.RESET;
                                IncomeExpenseAccount.SETRANGE("Store No.", Transaction."Store No.");
                                IncomeExpenseAccount.SETRANGE("No.", IncExpEntry."No.");
                                IF IncomeExpenseAccount.FINDFIRST THEN
                                    TipsText2 := IncomeExpenseAccount.Description
                                ELSE
                                    TipsText2 := 'Text321';
                            END;
                        END;
                END;
                IF NOT ThisIsAHospTipsLine THEN BEGIN
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    sender.AddPrintLine(340, 5, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                    //LS-11909-
                    IF Transaction."Customer Order ID" <> '' THEN BEGIN
                        CLEAR(Value);
                        Value[1] := 'ID: ' + Transaction."Customer Order ID";
                        NodeName[1] := 'Customer Order ID';
                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                        sender.AddPrintLine(340, 5, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                    END;
                    //LS-11909+
                    Value[1] := FORMAT(IncExpEntry."Line No.");
                    NodeName[1] := 'Line No.';
                    NodeName[2] := 'Extra Info Line';
                    IF IncExpAcc."Slip Text 1" <> '' THEN BEGIN
                        sender.PrintLine(Tray, IncExpAcc."Slip Text 1");
                        Value[2] := IncExpAcc."Slip Text 1";
                        sender.AddPrintLine(350, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                    END;
                    IF IncExpAcc."Slip Text 2" <> '' THEN BEGIN
                        sender.PrintLine(Tray, IncExpAcc."Slip Text 2");
                        Value[2] := IncExpAcc."Slip Text 2";
                        sender.AddPrintLine(350, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                    END;
                END;
                TransInfoEntry.SETRANGE("Store No.", Transaction."Store No.");
                TransInfoEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
                TransInfoEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
                TransInfoEntry.SETRANGE("Transaction Type", TransInfoEntry."Transaction Type"::"Income/Expense Entry");
                TransInfoEntry.SETRANGE("Line No.", IncExpEntry."Line No.");
                sender.PrintTransInfoCode(TransInfoEntry, Tray, FALSE);
            UNTIL IncExpEntry.NEXT = 0;
            //  sender.PrintSeperator(Tray);
        END;

        IF POSTerminal."Print Number of Items" AND (TotalNumberOfItems <> 0) THEN BEGIN
            CLEAR(Value);
            DSTR1 := '#L####################### #R#########';
            Value[1] := 'Text151';
            NodeName[1] := 'Total Text';
            Value[2] := POSFunctions.FormatQty(TotalNumberOfItems);
            NodeName[2] := 'Total Amount';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            sender.AddPrintLine(800, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
            // sender.PrintSeperator(Tray);
        END;

        IF POSTerminal."Print Total Savings" AND (TotalSavings <> 0) THEN BEGIN
            CLEAR(Value);
            DSTR1 := '#L####################### #R#########';
            Value[1] := 'Text152';
            NodeName[1] := 'Total Text';
            Value[2] := POSFunctions.FormatAmount(TotalSavings);
            NodeName[2] := 'Total Amount';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            sender.AddPrintLine(800, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
            //  sender.PrintSeperator(Tray);
        END;

        VATPrinted := FALSE;

        IF NOT GenPosFunc."Skip VAT on Receipt" AND NOT Transaction."Post as Shipment" THEN BEGIN
            FOR i := 1 TO 5 DO BEGIN
                IF VATCode[i] <> '' THEN BEGIN
                    IF i = 1 THEN BEGIN
                        DSTR1 := '#R########### #R##### #R##### #R########';
                        Value[4] := 'الصافي';
                        Value[3] := '';
                        Value[2] := 'ضريبة';
                        Value[1] := 'المجموع';
                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    END;
                    //DSTR1 := '#L #N## #N######## #N######## #N########';
                    DSTR1 := '#L #N######## #N##### #N##### #N########';
                    VATPrinted := TRUE;
                    Value[1] := VATCode[i];
                    NodeName[1] := 'VAT Code';//edmabodon

                    lAmount += -SalesAmountVAT[i];
                    Value[2] := POSFunctions.FormatAmount(lAmount);
                    NodeName[2] := 'Amount';
                    lVATAmount += -VATAmount[i];
                    Value[3] := POSFunctions.FormatAmount(lVATAmount);
                    NodeName[3] := 'VAT Amount';
                    Value[4] := '';//FORMAT(VATPerc[i]);
                    NodeName[4] := 'VAT %';
                    lNetAmount += -SalesAmountVAT[i] + VATAmount[i];
                    Value[5] := POSFunctions.FormatAmount(lNetAmount);
                    NodeName[5] := 'Net Amount';



                    //PrintLine(Tray,FormatLine(FormatStr(Value,DSTR1),FALSE,FALSE,FALSE,FALSE));
                    //AddPrintLine(900,5,NodeName,Value,DSTR1,FALSE,FALSE,FALSE,FALSE,Tray);
                END;
            END;
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            sender.AddPrintLine(900, 5, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);

        END;

        gVATAmount := lVATAmount;
        IF VATPrinted THEN
            sender.PrintSeperator(Tray);

        DSTR1 := '#R##### #R######## #R######## #R########';
        CLEAR(Value);
        PaymEntry.SETCURRENTKEY("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
        PaymEntry.SETRANGE("Store No.", Transaction."Store No.");
        PaymEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
        PaymEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
        PaymEntry.SETRANGE("Change Line", TRUE);
        IF PaymEntry.FINDFIRST THEN BEGIN
            REPEAT
                Value[1] := POSFunctions.FormatAmount(-PaymEntry."Amount Tendered");
            UNTIL PaymEntry.NEXT = 0;
        END;
        Value[2] := 'المرتجع';
        PaymEntry.SETRANGE("Change Line", FALSE);
        IF PaymEntry.FINDFIRST THEN BEGIN
            REPEAT
                IF PaymEntry."Change Line" = TRUE THEN
                    lTotalAmountTendered -= PaymEntry."Amount Tendered";
                lTotalAmountTendered += PaymEntry."Amount Tendered";
            UNTIL PaymEntry.NEXT = 0;
        END;
        Value[3] += POSFunctions.FormatAmount(lTotalAmountTendered);
        Value[4] := 'المدفوع';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
        // sender.PrintSeperator(Tray);
        sender.PrintSeperator(Tray);

        DSTR1 := '#R##### #R######## #R######## #R########';
        Value[4] := 'المبلغ';
        Value[3] := 'العملة';
        Value[2] := 'الدفع';
        Value[1] := 'المحتسب';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
        sender.PrintSeperator(Tray);

        //EDMABODON_Get all tender lines ++
        PaymEntry.SETRANGE("Change Line", FALSE);
        IF PaymEntry.FIND('-') THEN BEGIN
            REPEAT
                DSTR1 := '#R##### #R######## #R######## #R########';
                CLEAR(Value);
                Value[4] := POSFunctions.FormatAmount(PaymEntry."Amount in Currency");
                IF PaymEntry."Currency Code" = '' THEN
                    Value[3] := 'ريال'
                ELSE BEGIN
                    IF Currency.GET(PaymEntry."Currency Code") THEN
                        Value[3] := Currency."Description 2"
                    ELSE
                        Value[3] := PaymEntry."Currency Code";
                END;
                IF TenderType.GET(PaymEntry."Store No.", PaymEntry."Tender Type") THEN BEGIN
                    TransInfocodeEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
                    TransInfocodeEntry.SETRANGE("Transaction Type", TransInfocodeEntry."Transaction Type"::"Payment Entry");
                    TransInfocodeEntry.SETRANGE(Infocode, 'APPCODE');
                    TransInfocodeEntry.SETRANGE("Source Code", TenderType.Code);
                    //EDMABODON_20210131: Print Approval Code ATM ++
                    lPOSCardEntry.SETRANGE("Receipt No.", Transaction."Receipt No.");
                    lPOSCardEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
                    //EDMABODON_20210131: Print Approval Code ATM --
                    //EDMABODON: Print Tender Type: EFT ++
                    IF TenderTypeCardSetup.GET(PaymEntry."Store No.", PaymEntry."Tender Type", PaymEntry."Card No.") THEN
                        Value[2] := TenderTypeCardSetup.Description
                    ELSE
                        Value[2] := TenderType.Description;
                    //END;
                    Value[1] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    //EDMABODON: Print Tender Type: EFT --
                    //EDMABODON_20210131: Print Approval Code for Cards ++
                    IF lPOSCardEntry.FINDFIRST THEN BEGIN
                        CLEAR(Value);
                        DSTR1 := '#R################ #R###################';
                        Value[1] := lPOSCardEntry."Auth.code";
                        Value[2] := 'رمز الموافقة';
                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    END
                    ELSE
                        IF TransInfocodeEntry.FINDFIRST THEN BEGIN
                            CLEAR(Value);
                            DSTR1 := '#R################ #R###################';
                            Value[1] := TransInfocodeEntry.Information;
                            Value[2] := 'رمز الموافقة';
                            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                        END;
                    //EDMABODON_20210131: Print Approval Code for Cards --
                END;
                sender.PrintSeperator(Tray);
            UNTIL PaymEntry.NEXT = 0;
        END;

        //EDMABODON_Get all tender lines --
        IF PosSetup."Print Discount Detail" THEN BEGIN
            DSTR1 := '#L################# #R###############   ';
            discountSection := FALSE;
            IF (PerDiscOffArrCount > 0) THEN BEGIN
                sender.PrintLine(Tray, sender.FormatLine(COPYSTR('', 1, LineLen), FALSE, FALSE, FALSE, FALSE));
                discountSection := TRUE;
            END;

            FOR i := 1 TO PerDiscOffArrCount DO BEGIN
                maxCounter := 0;
                MixMatchEntry.SETRANGE("Store No.", SalesEntry."Store No.");
                MixMatchEntry.SETRANGE("POS Terminal No.", SalesEntry."POS Terminal No.");
                MixMatchEntry.SETRANGE("Transaction No.", SalesEntry."Transaction No.");
                IF MixMatchEntry.FIND('-') THEN
                    REPEAT
                        IF MixMatchEntry."Mix & Match Group" = PerDiscOffArr[i] THEN
                            IF MixMatchEntry.Counter > maxCounter THEN
                                maxCounter := MixMatchEntry.Counter;
                    UNTIL MixMatchEntry.NEXT = 0;

                IF PeriodicDiscount.GET(PerDiscOffArr[i]) THEN BEGIN
                    IF maxCounter = 0 THEN
                        Value[1] := PeriodicDiscount.Description
                    ELSE
                        Value[1] := FORMAT(maxCounter) + 'x ' + PeriodicDiscount.Description;
                END ELSE
                    Value[1] := FORMAT(PeriodicDiscount.Type);
                Value[2] := POSFunctions.FormatAmount(PerDiscOffAmtArr[i]);
                sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            END;
        END;

        IF discountSection THEN
            sender.PrintSeperator(Tray);

        IF Tray = 2 THEN
            sender.PrintCardSlipFromEFTEmbedded('E', Transaction); //LS-12379

        glTrans.INIT;


    end;

    procedure PrintSalesInfoENG(VAR Transaction: Record "Transaction Header"; Tray: Integer; GenPosFunc: Record "POS Functionality Profile";
        sender: Codeunit "POS Print Utility"; IsInvoice: Boolean; bSecondPrintActive: Boolean; LineLen: Integer)

    var
        StringLenBeforeSplitLine: Integer;
        TransInfoCode: Record "Trans. Infocode Entry";
        Customer: Record Customer;
        DSTR1: Text;
        Value: array[10] of Text;
        NodeName: array[10] of Text;
        Contact: Record Contact;
        PerDiscOffArrCount: Integer;
        totalCustItemDisc: Integer;
        TotalNumberOfItems: Integer;
        TotalSavings: Integer;
        LineCount: Integer;
        VATCode: array[10] of Code[10];
        TotalAmt: Decimal;
        TipsAmount1: Decimal;
        TipsText1: Text;
        TipsAmount2: Decimal;
        TipsText2: Text;
        glTrans: Record "Transaction Header";
        ParentItemLine: Record "Trans. Sales Entry";
        SalesEntry: Record "Trans. Sales Entry";
        SalesEntry2: Record "Trans. Sales Entry";
        CompressItemOK: Boolean;
        CountItemOk: Boolean;
        LastDepartment: Text;
        PrintItemNo: Integer;

        Subtotal: Decimal;
        OrderByDepartment: Boolean;
        POSTerminal: Record "POS Terminal";
        Item: Record Item;
        ParentItem: Record Item;
        LinkedItems: Record "Linked Item";
        NegativeQty: Integer;
        LastQuantity: Integer;
        VATNotSet: Boolean;
        VATPostingSetup: Record "VAT Posting Setup";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        lUOM: Record "Unit of Measure";
        DiscountOnLine: Decimal;
        i: Integer;
        j: Integer;
        POSFunctions: Codeunit "POS Functions";
        SalesLineAmount: Decimal;
        Store: Record Store;
        ItemName: Text;
        PeriodicDiscountInfoTEMP: Record "Periodic Discount" TEMPORARY;
        RecipeBufferTEMP: Record "Trans. Sales Entry" TEMPORARY;
        //   RecipeBufferTransInfoTEMP: Record "Trans. Sales Entry";
        // RecipeBufferDetailTEMP_l: Record "Trans. Sales Entry";
        RecipeBufferTEMP2: Record "Trans. Sales Entry" temporary;
        RecipeBufferTransInfoTextTEMP: Record "Trans. Infocode Entry" TEMPORARY;
        RecipeBufferTransInfoTEMP: Record "Trans. Infocode Entry" TEMPORARY;
        RecipeBufferDetailTEMP_l: Record "Trans. Discount Entry" TEMPORARY;
        ItemSoldUOMFactor: Decimal;
        TmpValue: Text;
        IncExpEntry: Record "Trans. Income/Expense Entry";
        DSTR2: Text;
        lItemName2: Text;
        DiscountText: Text;
        CouponHeader: Record "Coupon Header";
        PeriodicDiscount: Record "Periodic Discount";
        TransInfoEntry: Record "Trans. Infocode Entry";
        IncExpAcc: Record "Income/Expense Account";
        IncomeExpenseAccount: Record "Income/Expense Account";
        ThisIsAHospTipsLine: Boolean;
        PaymEntry: Record "Trans. Payment Entry";
        TenderType: Record "Tender Type";
        TransInfocodeEntry: Record "Trans. Infocode Entry";
        lPOSCardEntry: Record "POS Card Entry";
        MixMatchEntry: Record "Trans. Mix & Match Entry";
        TenderTypeCardSetup: Record "Tender Type Card Setup";
        PosSetup: Record "POS Hardware Profile";
        TipsStaff_l: Record Staff;
        discountSection: Boolean;
        lTotalAmountTendered: Decimal;
        VATSetup: Record "POS VAT Code";
        VATPerc: array[15] of Decimal;
        VATAmount: array[15] of Decimal;
        SalesAmountVAT: array[15] of Decimal;
        VATPrinted: Boolean;
        lNetAmount: Decimal;
        maxCounter: Integer;
        lVATAmount: Decimal;
        lAmount: Decimal;
        HospitalityType: Record "Hospitality Type";
        Currency: Record Currency;
        PerDiscOffArr: array[10] of Code[23];
        PerDiscOffAmtArr: array[10] of Decimal;

    begin

        //PrintSalesInfo


        StringLenBeforeSplitLine := 11;

        IF GenPosFunc."Multiple Items Symbol" = '' THEN
            GenPosFunc."Multiple Items Symbol" := ' x ';

        TransInfoCode.SETRANGE("Store No.", Transaction."Store No.");
        TransInfoCode.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
        TransInfoCode.SETRANGE("Transaction No.", Transaction."Transaction No.");
        TransInfoCode.SETRANGE("Transaction Type", TransInfoCode."Transaction Type"::Header);
        if (TransInfoCode.FindFirst())
        then begin
            sender.PrintTransInfoCode(TransInfoCode, Tray, TRUE);
        end;


        CLEAR(Customer);

        DSTR1 := '#T######################################';

        IF Transaction."Customer No." <> '' THEN BEGIN
            IF Transaction."Post as Shipment" THEN BEGIN
                Value[1] := '';
                NodeName[1] := 'Print Info';
                sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, '#C##################'), TRUE, TRUE, TRUE, FALSE));
                sender.AddPrintLine(250, 1, NodeName, Value, '#C##################', TRUE, TRUE, TRUE, FALSE, Tray);
                sender.PrintLine(Tray, '');
            END;
            IF Customer.GET(Transaction."Customer No.") THEN BEGIN
                Value[1] := COPYSTR(Customer."No." + ' ' + Customer.Name, 1, MAXSTRLEN(Value[1]));
                NodeName[1] := 'x';
                Value[2] := Customer."No.";
                NodeName[2] := 'Customer No.';
                Value[3] := Customer.Name;
                NodeName[3] := 'Customer Name';
                sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                sender.AddPrintLine(200, 3, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                sender.PrintSeperator(Tray);
            END;
        END;
        IF Transaction."Sell-to Contact No." <> '' THEN BEGIN
            IF Contact.GET(Transaction."Sell-to Contact No.") THEN BEGIN
                Value[1] := COPYSTR(Contact."No." + ' ' + Contact.Name, 1, MAXSTRLEN(Value[1]));
                NodeName[1] := 'x';
                Value[2] := Contact."No.";
                NodeName[2] := 'Contact No.';
                Value[3] := Contact.Name;
                NodeName[3] := 'Contact Name';
                sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                sender.AddPrintLine(200, 3, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                sender.PrintSeperator(Tray);
            END;
        END;
        IF Transaction."Sale Is Return Sale" THEN BEGIN
            Value[1] := '';
            NodeName[1] := 'Description';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, '#C##################'), TRUE, TRUE, TRUE, FALSE));
            sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
            sender.PrintSeperator(Tray);
        END;


        IF NOT IsInvoice THEN BEGIN
            IF Transaction.GetPrintedCounter(1) > 0 THEN
                sender.PrintCopyText(Tray)
            ELSE
                IF bSecondPrintActive THEN BEGIN
                    DSTR1 := '#C##################';
                    Value[1] := '';
                    DSTR1 := '#C' + sender.StringPad('#', LineLen - 2);
                    Value[1] := sender.StringPad('-', LineLen);
                END;
        END;

        IF Transaction."Entry Status" = Transaction."Entry Status"::Training THEN
            sender.PrintTrainingText(Tray);

        PerDiscOffArrCount := 0;
        totalCustItemDisc := 0;

        CLEAR(TotalNumberOfItems);
        CLEAR(TotalSavings);

        LineCount := 0;
        CLEAR(VATCode);
        CLEAR(VATPerc);
        CLEAR(VATAmount);
        CLEAR(SalesAmountVAT);
        CLEAR(SalesEntry);
        CLEAR(Value);
        //  tmpDeal.DELETEALL;
        //  TmpPrintedSalesEntry.DELETEALL;
        //  TmpPrintedDealPOSTransLine.DELETEALL;
        IF GenPosFunc."Print Disc/Cpn Info on Slip" IN
         [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
          GenPosFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total"] THEN BEGIN
            PeriodicDiscountInfoTEMP.RESET;
            PeriodicDiscountInfoTEMP.DELETEALL;
            Subtotal := 0;
        END;
        TotalAmt := 0;
        TipsAmount1 := 0;
        TipsText1 := '';
        TipsAmount2 := 0;
        TipsText2 := '';
        glTrans := Transaction;
        SalesEntry.SETRANGE("Store No.", Transaction."Store No.");
        SalesEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
        SalesEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
        OrderByDepartment := GenPosFunc."Receipt Printing by Category";
        IF OrderByDepartment THEN
            SalesEntry.SETCURRENTKEY("Item Category Code");
        IF SalesEntry.FIND('-') THEN BEGIN
            IF GenPosFunc."Print Free Text on Receipt" THEN BEGIN
                sender.PrintFreeTextLinesBeginning(SalesEntry, Tray, FALSE);
            END;
            DSTR1 := '#L##   #L######################## #L##### ';
            //Print Receipt Header
            //EDMABODON_20201004 

            Value[1] := '#';
            Value[2] := 'Item Name';
            Value[3] := 'Unit';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            // sender.PrintSeperator(Tray);

            //EDMABODON_20201004 ++
            //DSTR1 := '#L#######   #N########  #R#######  ##########   ';
            //DSTR1 := '#L#### #T###### #T###' + blankStr + '#L### #N#########';
            DSTR1 := '#L######## #N###### #N######## #R########';
            Value[1] := 'Qty';
            Value[2] := 'Price';
            Value[3] := 'VAT';
            Value[4] := 'Total';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
            sender.AddPrintLine(300, 4, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
            sender.PrintSeperator(Tray);
            //EDMABODON_20201004 --



            PrintItemNo := 0;
            IF POSTerminal.GET(SalesEntry."POS Terminal No.") THEN
                IF POSTerminal."Receipt Setup Location" = POSTerminal."Receipt Setup Location"::Store THEN BEGIN
                    CASE Store."Item No. on Receipt" OF
                        Store."Item No. on Receipt"::"Item Number":
                            PrintItemNo := 1;
                        Store."Item No. on Receipt"::"Barcode/Item Number":
                            PrintItemNo := 2;
                    END;
                END ELSE BEGIN
                    CASE POSTerminal."Item No. on Receipt" OF
                        POSTerminal."Item No. on Receipt"::"Item Number":
                            PrintItemNo := 1;
                        POSTerminal."Item No. on Receipt"::"Barcode/Item Number":
                            PrintItemNo := 2;
                    END;
                END;

            LastDepartment := '';
            RecipeBufferTEMP.RESET;
            RecipeBufferTEMP.DELETEALL;
            RecipeBufferDetailTEMP_l.RESET;
            RecipeBufferDetailTEMP_l.DELETEALL;
            RecipeBufferTEMP2.RESET;
            RecipeBufferTEMP2.DELETEALL;
            RecipeBufferTransInfoTEMP.RESET;
            RecipeBufferTransInfoTEMP.DELETEALL;
            RecipeBufferTransInfoTextTEMP.RESET;
            RecipeBufferTransInfoTextTEMP.DELETEALL;
            REPEAT
                CLEAR(Item);
                IF Item.GET(SalesEntry."Item No.") THEN;

                IF SalesEntry."Parent Line No." = 0 THEN BEGIN
                    ParentItem := Item;
                    ParentItemLine := SalesEntry;
                END;

                //All lines except deal lines are put into recipe-item buffer. For cases where lines must not be compressed, CompresItemOK is set as false
                CompressItemOK := TRUE;
                IF ParentItem."Skip Compression When Printed" THEN
                    CompressItemOK := FALSE;
                IF NOT (SalesEntry."Orig. from Infocode" <> '') AND (SalesEntry."Parent Line No." <> 0) THEN BEGIN
                    IF SalesEntry."Price Change" THEN
                        CompressItemOK := FALSE;
                    IF SalesEntry."Scale Item" THEN
                        CompressItemOK := FALSE;
                    IF SalesEntry."Price in Barcode" THEN
                        CompressItemOK := FALSE;
                    IF SalesEntry.Quantity > 0 THEN BEGIN
                        CompressItemOK := FALSE;
                        NegativeQty += 1;
                    END;
                    IF LastQuantity = 0 THEN
                        LastQuantity := SalesEntry.Quantity;
                    IF (LastQuantity <> 0) AND ((LastQuantity < 0) OR (SalesEntry.Quantity < 0)) AND (NegativeQty <> 0) THEN BEGIN
                        CompressItemOK := FALSE;
                        LastQuantity := 0;
                    END;
                END;
                IF (NOT SalesEntry."Deal Line") THEN
                    sender.InsertIntoRecipeBuffer(
                        SalesEntry, RecipeBufferTEMP, RecipeBufferTEMP2, ParentItemLine, RecipeBufferDetailTEMP_l,
                        RecipeBufferTransInfoTEMP, RecipeBufferTransInfoTextTEMP, CompressItemOK);

                IF POSTerminal."Print Total Savings" THEN BEGIN
                    TotalSavings := TotalSavings + SalesEntry."Discount Amount";
                END;

                IF POSTerminal."Print Number of Items" THEN BEGIN
                    IF (SalesEntry.Quantity < 0) THEN BEGIN
                        CountItemOk := TRUE;
                        IF SalesEntry."Linked No. not Orig." THEN BEGIN
                            SalesEntry2.RESET;
                            SalesEntry2.COPYFILTERS(SalesEntry);
                            IF SalesEntry2.FIND('-') THEN BEGIN
                                REPEAT
                                    IF (SalesEntry2."Item No." <> SalesEntry."Item No.") AND SalesEntry2."Orig. of a Linked Item List" THEN BEGIN
                                        LinkedItems.RESET;
                                        LinkedItems.SETRANGE("Item No.", SalesEntry2."Item No.");
                                        LinkedItems.SETRANGE("Linked Item No.", SalesEntry."Item No.");
                                        LinkedItems.SETFILTER("Sales Type", '%1|%2', '', Transaction."Sales Type");
                                        IF LinkedItems.FINDFIRST THEN BEGIN
                                            IF LinkedItems."Deposit Item" THEN
                                                CountItemOk := FALSE;
                                        END;
                                    END;
                                UNTIL (SalesEntry2.NEXT = 0) OR NOT CountItemOk;
                            END;
                        END;

                        IF CountItemOk THEN BEGIN
                            IF ItemUnitOfMeasure.GET(SalesEntry."Item No.", SalesEntry."Unit of Measure") THEN BEGIN
                                IF ItemUnitOfMeasure."Count as 1 on Receipt" THEN
                                    TotalNumberOfItems := TotalNumberOfItems + 1
                                ELSE
                                    TotalNumberOfItems := TotalNumberOfItems + ABS(SalesEntry.Quantity);
                            END ELSE
                                TotalNumberOfItems := TotalNumberOfItems + ABS(SalesEntry.Quantity);
                        END;

                    END;
                END;

                IF SalesEntry."Deal Line" THEN BEGIN
                    sender.PrintDeal(SalesEntry, Tray, PrintItemNo);
                    sender.CollectDiscInfo(SalesEntry, Tray, TotalAmt, Subtotal, PeriodicDiscountInfoTEMP);
                    IF GenPosFunc."Print Disc/Cpn Info on Slip" =
                      GenPosFunc."Print Disc/Cpn Info on Slip"::"No printing"
                    THEN
                        SalesLineAmount := SalesEntry."Net Amount" + SalesEntry."VAT Amount"
                    ELSE
                        SalesLineAmount :=
                          SalesEntry."Net Amount" + SalesEntry."VAT Amount"
                          - SalesEntry."Discount Amount";
                    IF GenPosFunc."Print Disc/Cpn Info on Slip" =
                        GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line"
                    THEN
                        TotalAmt := TotalAmt + SalesLineAmount
                    ELSE
                        IF GenPosFunc."Print Disc/Cpn Info on Slip" =
                          GenPosFunc."Print Disc/Cpn Info on Slip"::"No printing"
                        THEN
                            TotalAmt := TotalAmt + SalesLineAmount;
                    //*************** normal line, not deal line printed with recipe-item buffer
                END ELSE BEGIN
                    sender.CollectDiscInfo(SalesEntry, Tray, TotalAmt, Subtotal, PeriodicDiscountInfoTEMP);
                END;

                totalCustItemDisc := totalCustItemDisc + SalesEntry."Infocode Discount";

                i := 0;
                j := 0;
                VATNotSet := TRUE;
                IF SalesEntry."Net Amount" > 0 THEN
                    IF Item.GET(SalesEntry."Item No.") THEN
                        IF VATPostingSetup.GET(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") THEN
                            IF VATSetup.GET(VATPostingSetup."POS Terminal VAT Code") THEN
                                VATNotSet := FALSE;
                IF VATNotSet THEN
                    IF VATSetup.GET(SalesEntry."VAT Code") THEN
                        VATNotSet := FALSE;
                IF (VATSetup."VAT Code" <> '') AND NOT VATNotSet THEN BEGIN
                    REPEAT
                        i := i + 1;
                        IF j = 0 THEN
                            IF VATCode[i] = '' THEN
                                j := i;
                    UNTIL (VATCode[i] = VATSetup."VAT Code") OR (i >= 5);
                    IF VATCode[i] <> VATSetup."VAT Code" THEN BEGIN
                        i := j;
                        VATPerc[i] := VATSetup."VAT %";
                        VATCode[i] := VATSetup."VAT Code";
                    END;
                    VATAmount[i] := VATAmount[i] + SalesEntry."VAT Amount";
                    //  gVATAmount := gVATAmount + VATAmount[i];
                    SalesAmountVAT[i] := SalesAmountVAT[i] + SalesEntry."Net Amount" + SalesEntry."VAT Amount";
                END;
                LineCount := LineCount + 1;
            UNTIL SalesEntry.NEXT = 0;
        END;

        RecipeBufferTEMP.RESET;
        RecipeBufferTEMP2.RESET;
        RecipeBufferTEMP.SETRANGE("Parent Line No.", 0);
        IF OrderByDepartment THEN
            RecipeBufferTEMP.SETCURRENTKEY("Item Category Code");
        IF RecipeBufferTEMP.FIND('-') THEN
            REPEAT
                IF OrderByDepartment AND (RecipeBufferTEMP."Item Category Code" <> LastDepartment) THEN BEGIN
                    DSTR1 := '#L######################################';
                    Value[1] := RecipeBufferTEMP."Item Category Code";
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, TRUE, FALSE, FALSE));
                    LastDepartment := RecipeBufferTEMP."Item Category Code";
                END;

                DiscountOnLine := 0;
                IF GenPosFunc."Print Disc/Cpn Info on Slip" IN
                  [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line",
                   GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                   GenPosFunc."Print Disc/Cpn Info on Slip"::"Summary information below Sub-total"] THEN BEGIN
                    // DiscountOnLine := -RecipeBufferTEMP."Discount Amount";
                END;

                ItemName := GetItemNameEng(RecipeBufferTEMP."Item No.", RecipeBufferTEMP."Variant Code", Customer."Language Code", Store."Language Code");

                DSTR1 := '#L######### #L###################';
                IF PrintItemNo <> 0 THEN BEGIN
                    IF PrintItemNo = 1 THEN BEGIN
                        Value[1] := 'Text074';
                        NodeName[1] := 'x';
                        Value[2] := RecipeBufferTEMP."Item No.";
                        NodeName[2] := 'Item No.';
                    END
                    ELSE BEGIN
                        IF RecipeBufferTEMP."Barcode No." <> '' THEN BEGIN
                            Value[1] := 'Text075';
                            NodeName[1] := 'x';
                            Value[2] := RecipeBufferTEMP."Barcode No.";
                            NodeName[2] := 'Barcode';
                        END
                        ELSE BEGIN
                            Value[1] := 'Text074';
                            NodeName[1] := 'x';
                            Value[2] := RecipeBufferTEMP."Item No.";
                            NodeName[2] := 'Item No.';
                        END;
                    END;
                    Value[3] := FORMAT(RecipeBufferTEMP."Line No.");
                    NodeName[3] := 'Line No.';
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    sender.AddPrintLine(300, 3, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                END;


                IF (ABS(RecipeBufferTEMP.Quantity) <> 1) OR
                   ((RecipeBufferTEMP."UOM Quantity" <> 0) AND (ABS(RecipeBufferTEMP."UOM Quantity") <> 1)) OR
                   RecipeBufferTEMP."Scale Item" OR               //details always printed.
                   RecipeBufferTEMP."Price in Barcode"
                THEN BEGIN
                    //EDMSTOP

                    //DSTR1 := '#L## #L###### #R############################';
                    DSTR1 := '#L# #L########################## #R###';
                    // EDMABODON_20201202: Print Arabic UOM ++
                    //Value[2] := RecipeBufferTEMP."Unit of Measure";
                    CLEAR(lUOM);
                    IF lUOM.GET(RecipeBufferTEMP."Unit of Measure") THEN
                        Value[1] := lUOM."Description";
                    // EDMABODON_20201202: Print Arabic UOM --
                    NodeName[1] := 'UOM ID';
                    IF STRLEN(ItemName) > 30 THEN BEGIN
                        Value[2] := COPYSTR(ItemName, 1, 30);
                    END ELSE
                        Value[2] := ItemName;
                    NodeName[2] := 'Item Description';
                    Value[3] := FORMAT(RecipeBufferTEMP."POS Trans. Line No.");
                    NodeName[3] := 'LineNO';
                    Value[4] := FORMAT(RecipeBufferTEMP."POS Trans. Line No.");
                    NodeName[4] := 'Line No.';
                    Value[5] := RecipeBufferTEMP."Item No.";
                    NodeName[5] := 'Item No.';
                    Value[6] := RecipeBufferTEMP."Variant Code";
                    NodeName[6] := 'Variant Code';
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    sender.AddPrintLine(300, 4, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);

                    CLEAR(Value);
                    DSTR1 := '   #L################### #N########## #R';
                    IF RecipeBufferTEMP."Scale Item" OR RecipeBufferTEMP."Price in Barcode" THEN BEGIN
                        IF RecipeBufferTEMP."Weight Manually Entered" THEN
                            DSTR1 := 'MAN #L################## #N########## #R';
                        Value[1] :=
                          Value[1] + POSFunctions.FormatWeight(-RecipeBufferTEMP.Quantity, RecipeBufferTEMP."Unit of Measure") +
                          ' ' + GenPosFunc."Multiple Items Symbol" + ' ';
                        TmpValue := POSFunctions.FormatPricePrUnit(RecipeBufferTEMP.Price, RecipeBufferTEMP."Unit of Measure");
                        IF Item.GET(RecipeBufferTEMP."Item No.") THEN
                            IF RecipeBufferTEMP."Unit of Measure" <> Item."Base Unit of Measure" THEN BEGIN
                                ItemSoldUOMFactor := 0;
                                IF ItemUnitOfMeasure.GET(RecipeBufferTEMP."Item No.", RecipeBufferTEMP."Unit of Measure") THEN
                                    ItemSoldUOMFactor := ItemUnitOfMeasure."Qty. per Unit of Measure";
                                IF (ItemSoldUOMFactor <> 1) AND (ItemSoldUOMFactor <> 0) THEN BEGIN
                                    Value[1] := POSFunctions.FormatWeight(-RecipeBufferTEMP.Quantity / ItemSoldUOMFactor, RecipeBufferTEMP."Unit of Measure") +
                                      ' ' + GenPosFunc."Multiple Items Symbol" + ' ';
                                    TmpValue := POSFunctions.FormatPricePrUnit(RecipeBufferTEMP.Price * ItemSoldUOMFactor, RecipeBufferTEMP."Unit of Measure");
                                END;
                            END;
                        IF STRLEN(TmpValue) > StringLenBeforeSplitLine THEN BEGIN
                            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0), FALSE, FALSE));
                            Value[1] := TmpValue;
                        END ELSE
                            Value[1] := Value[1] + TmpValue;
                    END ELSE BEGIN
                        IF RecipeBufferTEMP."Unit of Measure" = '' THEN
                            RecipeBufferTEMP."Unit of Measure" := 'Text131';
                        IF RecipeBufferTEMP."UOM Quantity" <> 0 THEN BEGIN
                            RecipeBufferTEMP.Quantity := RecipeBufferTEMP."UOM Quantity";
                            RecipeBufferTEMP.Price := RecipeBufferTEMP."UOM Price";
                        END;
                        Value[1] :=
                          POSFunctions.FormatQty(-RecipeBufferTEMP.Quantity) + ' ' + LOWERCASE(RecipeBufferTEMP."Unit of Measure") +
                          ' ' + GenPosFunc."Multiple Items Symbol" + ' ';
                        Value[1] := Value[1] + POSFunctions.FormatPrice(RecipeBufferTEMP.Price);
                    END;
                    //DSTR1 := '#L####### #N##### #N############## #R##   ';
                    DSTR1 := '#L######## #N###### #N######## #R########';
                    Value[1] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + RecipeBufferTEMP."VAT Amount" + DiscountOnLine));
                    NodeName[1] := 'Amount';
                    Value[2] := FORMAT(-RecipeBufferTEMP."VAT Amount");
                    NodeName[2] := 'VAT Amount';
                    Value[3] := POSFunctions.FormatPrice(RecipeBufferTEMP.Price);
                    //Value[3] := POSFunctions.FormatPrice(RecipeBufferTEMP."Net Price");  //As per Al Amer Market decision 20210211 Abou zakaria to remove it
                    NodeName[3] := 'Price';
                    Value[4] := POSFunctions.FormatQty(-RecipeBufferTEMP.Quantity);
                    NodeName[4] := 'Quantity';
                    Value[5] := RecipeBufferTEMP."VAT Code";
                    NodeName[5] := 'VAT Code';
                    Value[6] := FORMAT(RecipeBufferTEMP."Line No.");
                    NodeName[6] := 'Line No.';
                    // EDMABODON_20201202: Print Arabic UOM ++
                    //Value[5] := RecipeBufferTEMP."Unit of Measure";
                    CLEAR(lUOM);
                    IF lUOM.GET(RecipeBufferTEMP."Unit of Measure") THEN
                        Value[5] := lUOM."Description";
                    // EDMABODON_20201202: Print Arabic UOM --
                    NodeName[5] := 'UOM ID';

                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0) or (RecipeBufferTEMP."Promotion No." <> ''), FALSE, FALSE));
                    sender.AddPrintLine(300, 7, NodeName, Value, DSTR1, FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0) or (RecipeBufferTEMP."Promotion No." <> ''), FALSE, FALSE, Tray);
                    PrintSeperator(Tray, sender);
                END
                ELSE BEGIN //EDMABODON Print Item lines

                    DSTR1 := '#L# #L########################## #R###';
                    // EDMABODON_20201202: Print Arabic UOM ++
                    Value[3] := LOWERCASE(RecipeBufferTEMP."Unit of Measure");
                    CLEAR(lUOM);
                    IF lUOM.GET(RecipeBufferTEMP."Unit of Measure") THEN
                        Value[3] := lUOM."Description";
                    // EDMABODON_20201202: Print Arabic UOM --
                    NodeName[1] := 'Unit of Measure';
                    IF STRLEN(ItemName) > 30 THEN BEGIN
                        Value[2] := COPYSTR(ItemName, 1, 30);
                    END ELSE
                        Value[2] := ItemName;
                    NodeName[2] := 'Item Description';
                    Value[1] := FORMAT(RecipeBufferTEMP."POS Trans. Line No.");
                    NodeName[3] := 'LineNO';
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0) or (RecipeBufferTEMP."Promotion No." <> ''), FALSE, FALSE));
                    sender.AddPrintLine(300, 1, NodeName, Value, DSTR1, FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0) or (RecipeBufferTEMP."Promotion No." <> ''), FALSE, FALSE, Tray);
                    //EDMABODON Item Description on two rows ++
                    lItemName2 := COPYSTR(ItemName, 31, 41);
                    IF STRLEN(lItemName2) > 0 THEN BEGIN
                        CLEAR(Value);
                        Value[1] := lItemName2;
                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    END;
                    //EDMABODON
                    //DSTR1 := '#L###################### #N########## #R';
                    DSTR1 := '#L######## #N###### #N######## #R########';
                    CLEAR(Value);
                    CLEAR(NodeName);
                    Value[4] := POSFunctions.FormatAmount(-(RecipeBufferTEMP."Net Amount" + RecipeBufferTEMP."VAT Amount" + DiscountOnLine));
                    NodeName[1] := 'Price';
                    Value[3] := FORMAT(-RecipeBufferTEMP."VAT Amount");
                    NodeName[2] := 'VAT Amount';
                    Value[2] := POSFunctions.FormatPrice(RecipeBufferTEMP.Price);
                    //Value[3] := POSFunctions.FormatPrice(RecipeBufferTEMP."Net Price"); // As Per Al Amer Market Decision 20210211 Abou Zakaria remove it
                    NodeName[3] := 'Price';
                    Value[1] := POSFunctions.FormatQty(-RecipeBufferTEMP.Quantity);
                    NodeName[4] := 'Quantity';

                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0) or (RecipeBufferTEMP."Promotion No." <> ''), FALSE, FALSE));
                    sender.AddPrintLine(300, 4, NodeName, Value, DSTR1, FALSE, (RecipeBufferTEMP."Periodic Discount" <> 0) or (RecipeBufferTEMP."Promotion No." <> ''), FALSE, FALSE, Tray);
                    PrintSeperator(Tray, sender);
                END;
                IF GenPosFunc."Print Free Text on Receipt" THEN
                    sender.PrintFreeTextLinesFromBuffer(RecipeBufferTEMP, RecipeBufferTransInfoTextTEMP, Tray, FALSE);
                //TODO
                // sender.PrintItemPOSText(RecipeBufferTEMP."Item No.",Customer."Language Code",Store."Language Code",RecipeBufferTEMP."Line No.",Tray);

                RecipeBufferTransInfoTEMP.SETRANGE("Store No.", Transaction."Store No.");
                RecipeBufferTransInfoTEMP.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
                RecipeBufferTransInfoTEMP.SETRANGE("Transaction No.", Transaction."Transaction No.");
                RecipeBufferTransInfoTEMP.SETRANGE("Transaction Type", RecipeBufferTransInfoTEMP."Transaction Type"::"Sales Entry");
                RecipeBufferTransInfoTEMP.SETRANGE("Line No.", RecipeBufferTEMP."Line No.");
                sender.PrintTransInfoCode(RecipeBufferTransInfoTEMP, Tray, FALSE);

                IF GenPosFunc."Print Disc/Cpn Info on Slip" IN
                  [GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total",
                  GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail information for each line"]
                THEN BEGIN
                    RecipeBufferDetailTEMP_l.RESET;
                    RecipeBufferDetailTEMP_l.SETRANGE("Store No.", RecipeBufferTEMP."Store No.");
                    RecipeBufferDetailTEMP_l.SETRANGE("POS Terminal No.", RecipeBufferTEMP."POS Terminal No.");
                    RecipeBufferDetailTEMP_l.SETRANGE("Transaction No.", RecipeBufferTEMP."Transaction No.");
                    RecipeBufferDetailTEMP_l.SETRANGE(RecipeLineNo, RecipeBufferTEMP."Line No.");
                    IF RecipeBufferDetailTEMP_l.FINDSET THEN
                        REPEAT
                            IF RecipeBufferDetailTEMP_l."Offer Type" = RecipeBufferDetailTEMP_l."Offer Type"::Line THEN
                                DiscountText := 'Text084'
                            ELSE
                                DiscountText := FORMAT(RecipeBufferDetailTEMP_l."Offer Type");
                            CLEAR(PeriodicDiscount);
                            IF RecipeBufferDetailTEMP_l."Offer Type" = RecipeBufferDetailTEMP_l."Offer Type"::Coupon THEN BEGIN
                                IF CouponHeader.GET(RecipeBufferDetailTEMP_l."Offer No.") THEN
                                    DiscountText := CouponHeader.Description;
                            END ELSE
                                IF PeriodicDiscount.GET(RecipeBufferDetailTEMP_l."Offer No.") THEN
                                    DiscountText := PeriodicDiscount.Description
                                ELSE
                                    CASE RecipeBufferDetailTEMP_l."Offer Type" OF
                                        RecipeBufferDetailTEMP_l."Offer Type"::Total:
                                            DiscountText := 'Text024';
                                        RecipeBufferDetailTEMP_l."Offer Type"::Line:
                                            DiscountText := 'Text084';
                                        ELSE
                                            DiscountText := FORMAT(RecipeBufferDetailTEMP_l."Offer Type");
                                    END;
                            DiscountText := CONVERTSTR(DiscountText, '&', '+');
                            IF NOT PeriodicDiscount."Block Printing" THEN BEGIN
                                IF NOT RecipeBufferTEMP."Deal Line" THEN BEGIN
                                    IF RecipeBufferDetailTEMP_l."Discount Amount" <> 0 THEN BEGIN
                                        IF NOT ((RecipeBufferDetailTEMP_l."Offer Type" = RecipeBufferDetailTEMP_l."Offer Type"::Total) AND
                                          (GenPosFunc."Print Disc/Cpn Info on Slip" =
                                          GenPosFunc."Print Disc/Cpn Info on Slip"::"Detail for each line and Sub-total")) THEN BEGIN
                                            DSTR2 := '   #L################# #N############   ';
                                            Value[1] := DiscountText;
                                            NodeName[1] := 'Detail Text';
                                            Value[2] := POSFunctions.FormatAmount(-RecipeBufferDetailTEMP_l."Discount Amount");
                                            NodeName[2] := 'Detail Amount';
                                            Value[3] := FORMAT(RecipeBufferTEMP."Line No.");
                                            NodeName[3] := 'Line No.';
                                            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR2), FALSE, FALSE, FALSE, FALSE));
                                            sender.AddPrintLine(360, 3, NodeName, Value, DSTR2, FALSE, FALSE, FALSE, FALSE, Tray);
                                        END;
                                    END;
                                    IF RecipeBufferDetailTEMP_l.Points <> 0 THEN BEGIN
                                        DSTR2 := '   #L################# #N############   ';
                                        Value[1] := DiscountText;
                                        NodeName[1] := 'Detail Text';
                                        Value[2] := POSFunctions.FormatAmount(RecipeBufferDetailTEMP_l.Points) + ' ' + 'Text232';
                                        NodeName[2] := 'x';
                                        Value[3] := FORMAT(RecipeBufferTEMP."Line No.");
                                        NodeName[3] := 'Line No.';
                                        Value[4] := POSFunctions.FormatAmount(RecipeBufferDetailTEMP_l.Points);
                                        NodeName[4] := 'Detail Amount';
                                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR2), FALSE, FALSE, FALSE, FALSE));
                                        sender.AddPrintLine(360, 4, NodeName, Value, DSTR2, FALSE, FALSE, FALSE, FALSE, Tray);
                                    END;
                                END;
                            END;
                        UNTIL RecipeBufferDetailTEMP_l.NEXT = 0;
                END;

                RecipeBufferTEMP2.SETRANGE("Parent Line No.", RecipeBufferTEMP."Line No.");
                IF RecipeBufferTEMP2.FINDSET THEN
                    REPEAT
                        ItemName := GetItemNameEng(RecipeBufferTEMP2."Item No.", RecipeBufferTEMP2."Variant Code", Customer."Language Code", Store."Language Code");


                        DSTR1 := '#L######################################';
                        Value[1] := ItemName;
                        NodeName[1] := 'Item Description';
                        Value[2] := FORMAT(RecipeBufferTEMP2."Line No.");
                        NodeName[2] := 'Line No.';
                        Value[3] := RecipeBufferTEMP2."Item No.";
                        NodeName[3] := 'Item No.';
                        Value[4] := RecipeBufferTEMP2."Variant Code";
                        NodeName[4] := 'Variant Code';
                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                        sender.AddPrintLine(300, 4, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                        IF RecipeBufferTEMP2."Unit of Measure" = '' THEN
                            RecipeBufferTEMP2."Unit of Measure" := '¥ 젧';//Text131;
                        IF RecipeBufferTEMP2."UOM Quantity" <> 0 THEN BEGIN
                            RecipeBufferTEMP2.Quantity := RecipeBufferTEMP2."UOM Quantity";
                            RecipeBufferTEMP2.Price := RecipeBufferTEMP2."UOM Price";
                        END;
                        DSTR1 := '#L###################### #N########## #R';
                        Value[1] :=
                          POSFunctions.FormatQty(-RecipeBufferTEMP2.Quantity) + ' ' + LOWERCASE(RecipeBufferTEMP2."Unit of Measure") +
                          ' ' + GenPosFunc."Multiple Items Symbol" + ' ';
                        Value[1] := Value[1] + POSFunctions.FormatPrice(RecipeBufferTEMP2.Price);
                        NodeName[1] := 'x';
                        Value[2] := POSFunctions.FormatAmount(-(RecipeBufferTEMP2."Net Amount" + RecipeBufferTEMP2."VAT Amount"));
                        NodeName[2] := 'Amount';
                        Value[3] := RecipeBufferTEMP2."VAT Code";
                        NodeName[3] := 'VAT Code';
                        Value[4] := FORMAT(RecipeBufferTEMP2."Line No.");
                        NodeName[4] := 'Line No.';
                        // EDMABODON_20201202: Print Arabic UOM ++
                        Value[5] := RecipeBufferTEMP."Unit of Measure";
                        CLEAR(lUOM);
                        IF lUOM.GET(RecipeBufferTEMP."Unit of Measure") THEN
                            Value[2] := lUOM."Description";
                        // EDMABODON_20201202: Print Arabic UOM --
                        NodeName[5] := 'UOM ID';
                        Value[6] := POSFunctions.FormatQty(-RecipeBufferTEMP2.Quantity);
                        NodeName[6] := 'Quantity';
                        Value[7] := POSFunctions.FormatPrice(RecipeBufferTEMP2.Price);
                        NodeName[7] := 'Price';
                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, (RecipeBufferTEMP2."Periodic Discount" <> 0), FALSE, FALSE));
                        sender.AddPrintLine(300, 7, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                    UNTIL RecipeBufferTEMP2.NEXT = 0;
            UNTIL RecipeBufferTEMP.NEXT = 0;

        //LS-11909 LineCount := LineCount + PrintSPOSalesInfo(Transaction, Tray);
        //  IF LineCount > 0 THEN
        //   sender.PrintSeperator(Tray);

        IF totalCustItemDisc <> 0 THEN BEGIN
            DSTR1 := '#L################# #R###############   ';
            Value[1] := 'Text086';
            NodeName[1] := 'Total Text';
            Value[2] := POSFunctions.FormatAmount(totalCustItemDisc);
            NodeName[2] := 'Total Amount';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            sender.AddPrintLine(600, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
        END;

        IF Transaction."Customer Discount" <> 0 THEN BEGIN
            DSTR1 := '#L################# #R###############   ';
            Value[1] := 'Text085';
            NodeName[1] := 'Total Text';
            Value[2] := POSFunctions.FormatAmount(-Transaction."Customer Discount");
            NodeName[2] := 'Total Amount';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            sender.AddPrintLine(600, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
        END;

        IF (totalCustItemDisc <> 0) OR (Transaction."Customer Discount" <> 0) THEN
            sender.PrintSeperator(Tray);

        IncExpEntry.SETRANGE("Store No.", Transaction."Store No.");
        IncExpEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
        IncExpEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
        IF IncExpEntry.FIND('-') THEN BEGIN
            REPEAT
                IncExpAcc.GET(IncExpEntry."Store No.", IncExpEntry."No.");
                IF (IncExpAcc."Gratuity Type" = IncExpAcc."Gratuity Type"::Tips) AND
                  (IncExpAcc."Account Type" = IncExpAcc."Account Type"::Expense)
                THEN BEGIN
                    IF NOT (TipsStaff_l.GET(IncExpEntry."Staff ID")) THEN
                        TipsStaff_l."Name on Receipt" := IncExpEntry."Staff ID";
                    IncExpAcc.Description :=
                      COPYSTR(IncExpAcc.Description + ' ' + TipsStaff_l."Name on Receipt", 1, MAXSTRLEN(IncExpAcc.Description));
                END;
                DSTR1 := '#L#################### #N############';
                Value[1] := IncExpAcc.Description;
                NodeName[1] := 'Inc./Exp. Description';
                Value[2] := POSFunctions.FormatAmount(-IncExpEntry.Amount);
                NodeName[2] := 'Amount';
                Value[3] := IncExpEntry."VAT Code";
                NodeName[3] := 'VAT Code';
                Value[4] := FORMAT(IncExpEntry."Line No.");
                NodeName[4] := 'Line No.';
                Value[5] := IncExpEntry."No.";
                NodeName[5] := 'Income/Expense No.';
                DSTR1 := '#L#################### #N############ #R';

                IF IncExpEntry."VAT Code" <> '' THEN BEGIN
                    i := 0;
                    j := 0;
                    IF VATSetup.GET(IncExpEntry."VAT Code") THEN BEGIN
                        REPEAT
                            i := i + 1;
                            IF j = 0 THEN
                                IF VATCode[i] = '' THEN
                                    j := i;
                        UNTIL (VATCode[i] = VATSetup."VAT Code") OR (i >= 5);
                        IF VATCode[i] <> VATSetup."VAT Code" THEN BEGIN
                            i := j;
                            VATPerc[i] := VATSetup."VAT %";
                            VATCode[i] := VATSetup."VAT Code";
                        END;
                        VATAmount[i] := VATAmount[i] + IncExpEntry."VAT Amount";
                        SalesAmountVAT[i] := SalesAmountVAT[i] + IncExpEntry.Amount;
                    END;
                END;

                TotalAmt := TotalAmt + IncExpEntry.Amount;
                Subtotal := Subtotal + IncExpEntry.Amount;

                ThisIsAHospTipsLine := FALSE;
                IF IncExpEntry."No." <> '' THEN BEGIN
                    IF IncExpEntry."No." = HospitalityType."Tips Income Acc. 1" THEN BEGIN
                        ThisIsAHospTipsLine := TRUE;
                        TipsAmount1 := TipsAmount1 + IncExpEntry.Amount;
                        IF TipsText1 = '' THEN BEGIN
                            IncomeExpenseAccount.RESET;
                            IncomeExpenseAccount.SETRANGE("Store No.", Transaction."Store No.");
                            IncomeExpenseAccount.SETRANGE("No.", IncExpEntry."No.");
                            IF IncomeExpenseAccount.FINDFIRST THEN
                                TipsText1 := IncomeExpenseAccount.Description
                            ELSE
                                TipsText1 := 'Text321';
                        END
                    END
                    ELSE
                        IF IncExpEntry."No." = HospitalityType."Tips Income Acc. 2" THEN BEGIN
                            ThisIsAHospTipsLine := TRUE;
                            TipsAmount2 := TipsAmount2 + IncExpEntry.Amount;
                            IF TipsText2 = '' THEN BEGIN
                                IncomeExpenseAccount.RESET;
                                IncomeExpenseAccount.SETRANGE("Store No.", Transaction."Store No.");
                                IncomeExpenseAccount.SETRANGE("No.", IncExpEntry."No.");
                                IF IncomeExpenseAccount.FINDFIRST THEN
                                    TipsText2 := IncomeExpenseAccount.Description
                                ELSE
                                    TipsText2 := 'Text321';
                            END;
                        END;
                END;
                IF NOT ThisIsAHospTipsLine THEN BEGIN
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    sender.AddPrintLine(340, 5, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                    //LS-11909-
                    IF Transaction."Customer Order ID" <> '' THEN BEGIN
                        CLEAR(Value);
                        Value[1] := 'ID: ' + Transaction."Customer Order ID";
                        NodeName[1] := 'Customer Order ID';
                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                        sender.AddPrintLine(340, 5, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                    END;
                    //LS-11909+
                    Value[1] := FORMAT(IncExpEntry."Line No.");
                    NodeName[1] := 'Line No.';
                    NodeName[2] := 'Extra Info Line';
                    IF IncExpAcc."Slip Text 1" <> '' THEN BEGIN
                        sender.PrintLine(Tray, IncExpAcc."Slip Text 1");
                        Value[2] := IncExpAcc."Slip Text 1";
                        sender.AddPrintLine(350, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                    END;
                    IF IncExpAcc."Slip Text 2" <> '' THEN BEGIN
                        sender.PrintLine(Tray, IncExpAcc."Slip Text 2");
                        Value[2] := IncExpAcc."Slip Text 2";
                        sender.AddPrintLine(350, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                    END;
                END;
                TransInfoEntry.SETRANGE("Store No.", Transaction."Store No.");
                TransInfoEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
                TransInfoEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
                TransInfoEntry.SETRANGE("Transaction Type", TransInfoEntry."Transaction Type"::"Income/Expense Entry");
                TransInfoEntry.SETRANGE("Line No.", IncExpEntry."Line No.");
                sender.PrintTransInfoCode(TransInfoEntry, Tray, FALSE);
            UNTIL IncExpEntry.NEXT = 0;
            //  sender.PrintSeperator(Tray);
        END;

        IF POSTerminal."Print Number of Items" AND (TotalNumberOfItems <> 0) THEN BEGIN
            CLEAR(Value);
            DSTR1 := '#L####################### #R#########';
            Value[1] := 'Text151';
            NodeName[1] := 'Total Text';
            Value[2] := POSFunctions.FormatQty(TotalNumberOfItems);
            NodeName[2] := 'Total Amount';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            sender.AddPrintLine(800, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
            // sender.PrintSeperator(Tray);
        END;

        IF POSTerminal."Print Total Savings" AND (TotalSavings <> 0) THEN BEGIN
            CLEAR(Value);
            DSTR1 := '#L####################### #R#########';
            Value[1] := 'Text152';
            NodeName[1] := 'Total Text';
            Value[2] := POSFunctions.FormatAmount(TotalSavings);
            NodeName[2] := 'Total Amount';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            sender.AddPrintLine(800, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
            //  sender.PrintSeperator(Tray);
        END;

        VATPrinted := FALSE;

        IF NOT GenPosFunc."Skip VAT on Receipt" AND NOT Transaction."Post as Shipment" THEN BEGIN
            FOR i := 1 TO 5 DO BEGIN
                IF VATCode[i] <> '' THEN BEGIN
                    IF i = 1 THEN BEGIN
                        DSTR1 := '#R##### #R######## #R######## #R########';
                        Value[1] := '';
                        Value[2] := 'Diposit';
                        Value[3] := 'VAT';
                        Value[4] := 'Total';
                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    END;
                    //DSTR1 := '#L #N## #N######## #N######## #N########';
                    DSTR1 := '#L #N## #N######## #N######## #N########';
                    VATPrinted := TRUE;
                    Value[1] := VATCode[i];
                    NodeName[1] := 'VAT Code';//edmabodon
                    Value[2] := '';
                    lAmount += -SalesAmountVAT[i];
                    Value[3] := POSFunctions.FormatAmount(lAmount);
                    NodeName[2] := 'Amount';
                    lVATAmount += -VATAmount[i];
                    Value[4] := POSFunctions.FormatAmount(lVATAmount);
                    NodeName[3] := 'VAT Amount';

                    NodeName[4] := 'VAT %';
                    lNetAmount += -SalesAmountVAT[i] + VATAmount[i];
                    Value[5] := POSFunctions.FormatAmount(lNetAmount);
                    NodeName[5] := 'Net Amount';



                    //PrintLine(Tray,FormatLine(FormatStr(Value,DSTR1),FALSE,FALSE,FALSE,FALSE));
                    //AddPrintLine(900,5,NodeName,Value,DSTR1,FALSE,FALSE,FALSE,FALSE,Tray);
                END;
            END;
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            sender.AddPrintLine(900, 5, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);

        END;

        gVATAmount := lVATAmount;
        IF VATPrinted THEN
            sender.PrintSeperator(Tray);

        DSTR1 := '#L##### #L######## #L######## #L########';
        CLEAR(Value);
        PaymEntry.SETCURRENTKEY("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");
        PaymEntry.SETRANGE("Store No.", Transaction."Store No.");
        PaymEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
        PaymEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
        PaymEntry.SETRANGE("Change Line", TRUE);
        IF PaymEntry.FINDFIRST THEN BEGIN
            REPEAT
                Value[4] := POSFunctions.FormatAmount(-PaymEntry."Amount Tendered");
            UNTIL PaymEntry.NEXT = 0;
        END;
        Value[3] := 'Change';
        PaymEntry.SETRANGE("Change Line", FALSE);
        IF PaymEntry.FINDFIRST THEN BEGIN
            REPEAT
                IF PaymEntry."Change Line" = TRUE THEN
                    lTotalAmountTendered -= PaymEntry."Amount Tendered";
                lTotalAmountTendered += PaymEntry."Amount Tendered";
            UNTIL PaymEntry.NEXT = 0;
        END;
        Value[2] += POSFunctions.FormatAmount(lTotalAmountTendered);
        Value[1] := 'Paid';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
        // sender.PrintSeperator(Tray);
        sender.PrintSeperator(Tray);

        DSTR1 := '#L##### #L######## #L######## #L########';
        Value[1] := 'Amount';
        Value[2] := 'Currency';
        Value[3] := 'Payment';
        Value[4] := 'Balance';
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
        sender.PrintSeperator(Tray);

        //EDMABODON_Get all tender lines ++
        PaymEntry.SETRANGE("Change Line", FALSE);
        IF PaymEntry.FIND('-') THEN BEGIN
            REPEAT
                DSTR1 := '#L##### #L######## #L######## #L########';
                CLEAR(Value);
                Value[1] := POSFunctions.FormatAmount(PaymEntry."Amount in Currency");
                IF PaymEntry."Currency Code" = '' THEN
                    Value[2] := 'S.R'
                ELSE BEGIN
                    IF Currency.GET(PaymEntry."Currency Code") THEN
                        Value[2] := Currency."Description"
                    ELSE
                        Value[2] := PaymEntry."Currency Code";
                END;
                IF TenderType.GET(PaymEntry."Store No.", PaymEntry."Tender Type") THEN BEGIN
                    TransInfocodeEntry.SETRANGE("Transaction No.", Transaction."Transaction No.");
                    TransInfocodeEntry.SETRANGE("Transaction Type", TransInfocodeEntry."Transaction Type"::"Payment Entry");
                    TransInfocodeEntry.SETRANGE(Infocode, 'APPCODE');
                    TransInfocodeEntry.SETRANGE("Source Code", TenderType.Code);
                    //EDMABODON_20210131: Print Approval Code ATM ++
                    lPOSCardEntry.SETRANGE("Receipt No.", Transaction."Receipt No.");
                    lPOSCardEntry.SETRANGE("POS Terminal No.", Transaction."POS Terminal No.");
                    //EDMABODON_20210131: Print Approval Code ATM --
                    //EDMABODON: Print Tender Type: EFT ++
                    IF TenderTypeCardSetup.GET(PaymEntry."Store No.", PaymEntry."Tender Type", PaymEntry."Card No.") THEN
                        Value[3] := TenderTypeCardSetup.Description
                    ELSE
                        Value[3] := TenderType.Description;
                    //END;
                    Value[4] := POSFunctions.FormatAmount(PaymEntry."Amount Tendered");
                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    //EDMABODON: Print Tender Type: EFT --
                    //EDMABODON_20210131: Print Approval Code for Cards ++
                    IF lPOSCardEntry.FINDFIRST THEN BEGIN
                        CLEAR(Value);
                        DSTR1 := '#L################ #L###################';
                        Value[2] := lPOSCardEntry."Auth.code";
                        Value[1] := 'Approval Code';
                        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                    END
                    ELSE
                        IF TransInfocodeEntry.FINDFIRST THEN BEGIN
                            CLEAR(Value);
                            DSTR1 := '#L################ #L###################';
                            Value[2] := TransInfocodeEntry.Information;
                            Value[1] := 'Approval Code';
                            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
                        END;
                    //EDMABODON_20210131: Print Approval Code for Cards --
                END;
                sender.PrintSeperator(Tray);
            UNTIL PaymEntry.NEXT = 0;
        END;

        //EDMABODON_Get all tender lines --
        IF PosSetup."Print Discount Detail" THEN BEGIN
            DSTR1 := '#L################# #R###############   ';
            discountSection := FALSE;
            IF (PerDiscOffArrCount > 0) THEN BEGIN
                sender.PrintLine(Tray, sender.FormatLine(COPYSTR('', 1, LineLen), FALSE, FALSE, FALSE, FALSE));
                discountSection := TRUE;
            END;

            FOR i := 1 TO PerDiscOffArrCount DO BEGIN
                maxCounter := 0;
                MixMatchEntry.SETRANGE("Store No.", SalesEntry."Store No.");
                MixMatchEntry.SETRANGE("POS Terminal No.", SalesEntry."POS Terminal No.");
                MixMatchEntry.SETRANGE("Transaction No.", SalesEntry."Transaction No.");
                IF MixMatchEntry.FIND('-') THEN
                    REPEAT
                        IF MixMatchEntry."Mix & Match Group" = PerDiscOffArr[i] THEN
                            IF MixMatchEntry.Counter > maxCounter THEN
                                maxCounter := MixMatchEntry.Counter;
                    UNTIL MixMatchEntry.NEXT = 0;

                IF PeriodicDiscount.GET(PerDiscOffArr[i]) THEN BEGIN
                    IF maxCounter = 0 THEN
                        Value[1] := PeriodicDiscount.Description
                    ELSE
                        Value[1] := FORMAT(maxCounter) + 'x ' + PeriodicDiscount.Description;
                END ELSE
                    Value[1] := FORMAT(PeriodicDiscount.Type);
                Value[2] := POSFunctions.FormatAmount(PerDiscOffAmtArr[i]);
                sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
            END;
        END;

        IF discountSection THEN
            sender.PrintSeperator(Tray);

        IF Tray = 2 THEN
            sender.PrintCardSlipFromEFTEmbedded('E', Transaction); //LS-12379

        glTrans.INIT;


    end;

    LOCAL PROCEDURE GetItemName(ItemNo: Code[20]; VariantCode: Code[20]; CustLanguageCode: Code[10]; StoreLanguageCode: Code[10]): Text[100];
    VAR
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemName: Text;
    BEGIN
        IF Item.GET(ItemNo) THEN BEGIN
            IF (VariantCode <> '') AND
               (ItemVariant.GET(ItemNo, VariantCode))
            THEN BEGIN
                ItemName := COPYSTR(ItemVariant."Description 2", 1, 27);
                IF ItemName = '' THEN
                    ItemName := COPYSTR(ItemVariant.Description, 1, 27)
            END ELSE BEGIN
                ItemName := COPYSTR(Item."Description 2", 1, 27);
                IF ItemName = '' THEN
                    ItemName := COPYSTR(Item.Description, 1, 27)
            END
        END ELSE BEGIN
            ItemName := ItemNo;
            EXIT(ItemName);
        END;

        GetItemNameTranslation(ItemNo, VariantCode, CustLanguageCode, StoreLanguageCode, ItemName);
        EXIT(ItemName);
    END;

    LOCAL PROCEDURE GetItemNameEng(ItemNo: Code[20]; VariantCode: Code[20]; CustLanguageCode: Code[10]; StoreLanguageCode: Code[10]): Text[100];
    VAR
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemName: Text;
    BEGIN
        IF Item.GET(ItemNo) THEN BEGIN
            IF (VariantCode <> '') AND
               (ItemVariant.GET(ItemNo, VariantCode))
            THEN BEGIN
                ItemName := COPYSTR(ItemVariant."Description", 1, 27);
                IF ItemName = '' THEN
                    ItemName := COPYSTR(ItemVariant.Description, 1, 27)
            END ELSE BEGIN
                ItemName := COPYSTR(Item."Description", 1, 27);
                IF ItemName = '' THEN
                    ItemName := COPYSTR(Item.Description, 1, 27)
            END
        END ELSE BEGIN
            ItemName := ItemNo;
            EXIT(ItemName);
        END;

        GetItemNameTranslation(ItemNo, VariantCode, CustLanguageCode, StoreLanguageCode, ItemName);
        EXIT(ItemName);
    END;

    LOCAL PROCEDURE GetItemNameTranslation(ItemNo: Code[20]; VariantCode: Code[20]; CustLanguageCode: Code[10]; StoreLanguageCode: Code[10]; VAR ItemName: Text);
    VAR
        ItemTranslation: Record "Item Translation";
    BEGIN
        CLEAR(ItemTranslation);
        IF CustLanguageCode <> '' THEN BEGIN
            IF NOT ItemTranslation.GET(ItemNo, VariantCode, CustLanguageCode) THEN
                IF StoreLanguageCode <> '' THEN
                    IF ItemTranslation.GET(ItemNo, VariantCode, StoreLanguageCode) THEN;
        END ELSE
            IF StoreLanguageCode <> '' THEN
                IF ItemTranslation.GET(ItemNo, VariantCode, StoreLanguageCode) THEN;

        IF ItemTranslation.Description <> '' THEN
            ItemName := COPYSTR(ItemTranslation.Description, 1, 20);
    END;

    //OnAfterPrintLogo

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"POS Print Utility", 'OnAfterPrintLogo', '', true, true)]
    procedure PrintLogo(VAR Tray: Integer; VAR PrintBuffer: Record "POS Print Buffer"; VAR PrintBufferIndex: Integer; VAR LinesPrinted: Integer)
    begin
        PrintBuffer.SetFilter("Buffer Index", FORMAT(PrintBufferIndex), Tray);

        PrintBuffer.Height := 100;
        PrintBuffer.Width := 100;
        PrintBuffer.Modify();

    end;

    procedure PrintSeperator(Tray: Integer; sender: Codeunit "POS Print Utility")
    var
        LineLength: Integer;
        LineLen: Integer;
        InvLineLen: Integer;
    begin
        LineLen := 40;
        InvLineLen := 40;

        //PrintSeperator
        IF Tray = 2 THEN
            LineLength := LineLen
        ELSE
            IF Tray = 4 THEN
                LineLength := InvLineLen;

        //LS-12824+
        DSTR1 := '#C' + sender.StringPad('#', LineLength - 2);
        Value[1] := sender.StringPad('_', LineLength);
        sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), FALSE, FALSE, FALSE, FALSE));
    end;










    procedure PrintItemPOSText(ItemNo: Code[10]; CustLanguageCode: Code[10]; StoreLanguageCode: Code[10]; LineNo: Integer; Tray: Integer; sender: Codeunit "POS Print Utility")

    var
        TextFound: Boolean;
        ItemPosTextHeader: Record "Item POS Text Header";
        ItemPosTextLine: Record "Item POS Text Line";
        DSTR1: Text;
        Value: array[4] of Text;
        NodeName: array[4] of Text;
    begin




        TextFound := FALSE;
        CLEAR(ItemPosTextHeader);
        IF CustLanguageCode <> '' THEN
            IF ItemPosTextHeader.GET(ItemNo, ItemPosTextHeader."Text Type"::"Receipt Text", CustLanguageCode) THEN
                TextFound := TRUE;
        IF NOT TextFound THEN
            IF StoreLanguageCode <> '' THEN
                IF ItemPosTextHeader.GET(ItemNo, ItemPosTextHeader."Text Type"::"Receipt Text", StoreLanguageCode) THEN
                    TextFound := TRUE;
        IF NOT TextFound THEN
            IF ItemPosTextHeader.GET(ItemNo, ItemPosTextHeader."Text Type"::"Receipt Text", '') THEN
                TextFound := TRUE;

        IF TextFound THEN BEGIN
            ItemPosTextLine.RESET;
            ItemPosTextLine.SETRANGE("Item No.", ItemPosTextHeader."Item No.");
            ItemPosTextLine.SETRANGE("Text Type", ItemPosTextLine."Text Type"::"Receipt Text");
            ItemPosTextLine.SETRANGE("Language Code", ItemPosTextHeader."Language Code");
            DSTR1 := '#T######################################';
            IF ItemPosTextLine.FIND('-') THEN
                REPEAT
                    Value[1] := ItemPosTextLine.Text;
                    NodeName[1] := 'Extra Info Line';
                    Value[2] := FORMAT(LineNo);
                    NodeName[2] := 'Line No.';
                    sender.PrintLine(Tray, ItemPosTextLine.Text);
                    sender.AddPrintLine(350, 2, NodeName, Value, DSTR1, FALSE, FALSE, FALSE, FALSE, Tray);
                UNTIL ItemPosTextLine.NEXT = 0;
        END;

    end;




    PROCEDURE PrintHeader(Transaction: Record "Transaction Header"; PreReceipt: Boolean; Tray: Integer; sender: Codeunit "POS Print Utility"; Globals: Codeunit "POS Session"; UseTransactionStoreAndPOSForPrintHeader: Boolean);
    VAR
        POSText: Record 99001492;
        DSTR1: Text[100];
        LineLength: Integer;
        Terminal: Record 99001471;
        ReceiptHeader: Record 99001498;
        RetailUtil: Codeunit "Retail Price Utils";
        ReceiptNo: Code[20];
        SeatNo: Integer;
        PosTrGuestInfo: Record 10012117;
        Proceed: Boolean;
        Text217: TextConst ENU = 'Pre-Receipt';
    BEGIN
        //PrintHeader
        //LS-13176-
        IF UseTransactionStoreAndPOSForPrintHeader THEN
            UseTransactionStoreAndPOSForPrintHeader := FALSE
        ELSE BEGIN
            Transaction."Store No." := Globals.StoreNo;
            Transaction."POS Terminal No." := Globals.TerminalNo;
        END;

        //LS-12346+

        IF Tray = 2 THEN
            LineLength := 40
        ELSE
            IF Tray = 4 THEN
                LineLength := 40;

        //LS-13176 Terminal.GET(Globals.TerminalNo);
        Terminal.GET(Transaction."POS Terminal No.");

        CLEAR(ReceiptNo);
        ReceiptHeader.RESET;
        ReceiptHeader.SETCURRENTKEY(Priority);

        ReceiptHeader.SETRANGE("Receipt Setup Location", Terminal."Receipt Setup Location");

        IF ReceiptHeader.FINDLAST THEN BEGIN
            REPEAT
                IF RetailUtil.DiscValPerValid(ReceiptHeader."Validation Period ID", Transaction.Date, Transaction.Time) THEN BEGIN
                    ReceiptNo := ReceiptHeader."No.";
                END;
            UNTIL (ReceiptHeader.NEXT(-1) = 0) OR (ReceiptNo <> '');
        END;

        CLEAR(POSText);

        IF (ReceiptNo <> '') THEN
            POSText.SETRANGE("No.", ReceiptNo)
        ELSE
            POSText.SETRANGE("No.", '');

        IF Terminal."Receipt Setup Location" = Terminal."Receipt Setup Location"::Terminal THEN BEGIN
            POSText.SETRANGE(Relation, POSText.Relation::Terminal);
            //LS-13176 POSText.SETRANGE(Number,Globals.TerminalNo);
            POSText.SETRANGE(Number, Terminal."No."); //LS-13176
        END
        ELSE BEGIN
            POSText.SETRANGE(Relation, POSText.Relation::Store);
            //LS-13176 POSText.SETRANGE(Number,Globals.StoreNo);
            POSText.SETRANGE(Number, Transaction."Store No."); //LS-13176
        END;
        POSText.SETRANGE(Type, POSText.Type::Top);

        IF NOT POSText.FINDFIRST THEN
            POSText.SETRANGE("No.", '');

        if (Transaction."Sale Is Return Sale")
        then begin

            DSTR1 := COPYSTR('#C################################################', 1, LineLength);
            Value[1] := 'إشعار مدين الفاتورة الضريبة المبسطة';
            NodeName[1] := 'Header Line';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), POSText.Wide, POSText.Bold, POSText.High, POSText.Italic));
            sender.AddPrintLine(100, 1, NodeName, Value, DSTR1, POSText.Wide, POSText.Bold, POSText.High, POSText.Italic, Tray);
            sender.PrintSeperator(Tray);
        end else begin

            IF POSText.FINDSET THEN BEGIN
                REPEAT
                    CASE POSText.Align OF
                        POSText.Align::Left:
                            DSTR1 := COPYSTR('#L################################################', 1, LineLength);
                        POSText.Align::Center:
                            DSTR1 := COPYSTR('#C################################################', 1, LineLength);
                        POSText.Align::Right:
                            DSTR1 := COPYSTR('#R################################################', 1, LineLength);
                    END;
                    IF POSText.Wide THEN
                        DSTR1 := COPYSTR(DSTR1, 1, ROUND(STRLEN(DSTR1) / 2, 1, '>'));
                    Value[1] := POSText."Receipt Text";
                    NodeName[1] := 'Header Line';

                    sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), POSText.Wide, POSText.Bold, POSText.High, POSText.Italic));
                    sender.AddPrintLine(100, 1, NodeName, Value, DSTR1, POSText.Wide, POSText.Bold, POSText.High, POSText.Italic, Tray)
                UNTIL POSText.NEXT = 0;
                sender.PrintSeperator(Tray);
            END;
        end;
        IF PreReceipt THEN BEGIN
            Value[1] := Text217;
            NodeName[1] := 'Description';
            sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(Value, DSTR1), POSText.Wide, POSText.Bold, POSText.High, POSText.Italic));
            sender.AddPrintLine(200, 1, NodeName, Value, DSTR1, POSText.Wide, POSText.Bold, POSText.High, POSText.Italic, Tray);
            sender.PrintSeperator(Tray);
        END;


    END;



    /// <summary>
    /// PrintBitmap.
    /// </summary>
    /// <param name="Tray">Integer.</param>
    /// <param name="ClientFilePath">Text.</param>
    /// <param name="Alignment">Option Left,Center,Right.</param>
    /// <param name="PrintBuffer">Record "POS Print Buffer".</param>
    /// <param name="PrintBufferIndex">Integer.</param>
    /// <param name="PageNo">Integer.</param>
    /// <param name="LinesPrinted">Integer.</param>
    /// <returns>Return value of type Code[20].</returns>
    procedure PrintBitmap(Tray: Integer; ClientFilePath: Text; Alignment: Option Left,Center,Right; PrintBuffer: Record "POS Print Buffer"; PrintBufferIndex: Integer; PageNo: Integer; LinesPrinted: Integer): Code[20]
    var

    begin

        PrintBuffer.Init;
        PrintBuffer."Buffer Index" := PrintBufferIndex;
        PrintBuffer."Station No." := Tray;
        PrintBuffer."Page No." := PageNo;
        PrintBuffer."Printed Line No." := LinesPrinted;
        PrintBuffer.LineType := PrintBuffer.LineType::PrintBitmapFile;
        PrintBuffer.Text := ClientFilePath;
        PrintBuffer.BCPos := Alignment;
        PrintBuffer.Insert;
        PrintBufferIndex += 1;
        exit;
    end;

    /// <summary>
    /// addCommand.
    /// </summary>
    /// <param name="commandid">Text.</param>
    procedure addCommand(commandid: Text)

    var
        PosCommand: Record "POS Command";

    begin
        PosCommand.Reset();

        PosCommand.SetFilter("Function Code", commandid);
        if (PosCommand.FindFirst())

        then begin
            //     if not (PosCommand."Menu Function")
            //   PosCommand."Menu Function" := True;
            //   PosCommand.Modify();
        end
        else begin
            PosCommand.Init();
            PosCommand."Function Code" := commandid;
            PosCommand."Menu Function" := True;
            PosCommand.Insert();
        end;

    end;

}