table 50000 "Smarvy Coupon Code"
{
    Caption = 'Smarvy Coupon Code';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; Code; Code[200])
        {
            Caption = 'Code';
        }
        field(3; Used; Boolean)
        {
            Caption = 'Used';
        }
        field(4; "Used Date"; Date)
        {
            Caption = 'Used Date';
        }
        field(5; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            TableRelation = Store;
        }
        field(6; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
        }
        field(7; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
        }
        field(8; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Code; Code)
        {
        }
        key(Used; Used, "Entry No.")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Entry No." = 0 then
            "Entry No." := GetNextEntryNo();
    end;

    local procedure GetNextEntryNo(): Integer
    var
        SmarvyCouponCode: Record "Smarvy Coupon Code";
    begin
        SmarvyCouponCode.SetCurrentKey("Entry No.");
        if SmarvyCouponCode.FindLast() then
            exit(SmarvyCouponCode."Entry No." + 1);

        exit(1);
    end;
}
