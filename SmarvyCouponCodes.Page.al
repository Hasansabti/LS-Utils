page 50001 "Smarvy Coupon Codes"
{
    Caption = 'Smarvy Coupon Codes';
    PageType = List;
    SourceTable = "Smarvy Coupon Code";
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTableView = sorting("Entry No.");

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Code; Code)
                {
                    ApplicationArea = All;
                    Editable = not Used;
                }
                field(Used; Used)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Used Date"; "Used Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store No."; "Store No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("POS Terminal No."; "POS Terminal No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Transaction No."; "Transaction No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Receipt No."; "Receipt No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowAll)
            {
                ApplicationArea = All;
                Caption = 'Show All';
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Show all coupon codes.';

                trigger OnAction()
                begin
                    Rec.Reset();
                    CurrPage.Update(false);
                end;
            }
            action(ShowUnused)
            {
                ApplicationArea = All;
                Caption = 'Show Unused';
                Image = FilterLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Show only codes that have not been issued yet.';

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange(Used, false);
                    CurrPage.Update(false);
                end;
            }
            action(ShowUsed)
            {
                ApplicationArea = All;
                Caption = 'Show Used';
                Image = Completed;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Show only codes that have already been issued.';

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange(Used, true);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Used := false;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if Used then
            Error('Used coupon codes cannot be deleted.');

        exit(true);
    end;
}
