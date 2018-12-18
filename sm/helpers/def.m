function strct=def(strct,fldname,val)
% set value of struct field to default unless its already set. 
% function strct=def(strct,fldname,val)
if ~isfield(strct,fldname)
    strct.(fldname)=val;
end
end