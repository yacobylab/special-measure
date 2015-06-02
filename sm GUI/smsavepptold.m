% SAVEPPT saves plots to PowerPoint.
% function SAVEPPT(filespec,title,prnopt) saves the current Matlab figure
%  window or Simulink model window to a PowerPoint file designated by
%  filespec.  If filespec is omitted, the user is prompted to enter
%  one via UIPUTFILE.  If the path is omitted from filespec, the
%  PowerPoint file is created in the current Matlab working directory.
%
%  Optional input argument TITLE will add a title to the PowerPoint slide.
%
%  Optional input argument PRNOPT is used to specify additional save options:
%
%    -fHandle   Handle of figure window to save
%    -sName     Name of Simulink model window to save
%    -r###      Set bitmap resolution to ### dots/inch (This applies only to large
%               images which get converted to BMP when captured by the clipboard.)
%
%  Examples:
%  >> saveppt
%       Prompts user for valid filename and saves current figure
%  >> saveppt('junk.ppt')
%       Saves current figure to PowerPoint file called junk.ppt
%  >> saveppt('junk.ppt','Stock Price','-f3')
%       Saves figure #3 to PowerPoint file called junk.ppt with a
%       slide title of "Stock Price".
%  >> saveppt('models.ppt','System Block Diagram','-sMainBlock')
%       Saves Simulink model named "MainBlock" to file called models.ppt
%       with a slide title of "System Block Diagram".
%
%  The command-line method of invoking SAVEPPT will also work:
%  >> saveppt models.ppt 'System Block Diagram' -sMainBlock
%
%  However, if you want to save a specific figure or simulink model
%  without title text, you must use the function-call method:
%  >> saveppt('models.ppt','','-f8')

%Ver 2.2, Copyright 2005, Mark W. Brown, mwbrown@ieee.org
%  changed slide type to include title.
%  added input parameter for title text.
%  added support for int32 and single data types for Matlab 6.0
%  added comments about changing bitmap resolution (for large images only)
%  swapped order of opening PPT and copying to clipboard (thanks to David Abraham)
%  made PPT invisible during save operations (thanks to Noah Siegel)

function smsaveppt(filespec,text,prnopt)

% Establish valid file name:
if nargin<1 || isempty(filespec) 
  return
   [fname, fpath] = uiputfile('*.ppt');
  if fpath == 0; return; end
  filespec = fullfile(fpath,fname);
else
  [fpath,fname,fext] = fileparts(filespec);
  if isempty(fpath); fpath = pwd; end
  if isempty(fext); fext = '.ppt'; end
  filespec = fullfile(fpath,[fname,fext]);
end

% Default title and body text:
if nargin<2
  text.title = '';
  text.body = '';
end

% Start an ActiveX session with PowerPoint:
ppt = actxserver('PowerPoint.Application');

% Capture current figure/model into clipboard:
if nargin<3
  print -dmeta
else
  print('-dmeta',prnopt)
end

if ~exist(filespec,'file');
  % Create new presentation:
  op = invoke(ppt.Presentations,'Add');
else
  % First scan through open presentations
  numopen = ppt.Presentations.count;
  done = 0;
  for i = 1:numopen
      if strcmp(filespec,ppt.Presentations.Item(i).FullName)
          op = ppt.Presentations.Item(i);
          done = 1;
      end
  end
  % now open the file if it hasn't been found
  if done == 0
      op = ppt.Presentations.Open(filespec,[],[],0);
  end
end


% Get current number of slides:
slide_count = get(op.Slides,'Count');

% Add a new slide (with title object):
slide_count = int32(double(slide_count)+1);
new_slide = invoke(op.Slides,'Add',slide_count,11);

% Insert text into the title object:
set(new_slide.Shapes.Title.TextFrame.TextRange,'Text',text.title);

% Get height and width of slide:
slide_H = op.PageSetup.SlideHeight;
slide_W = op.PageSetup.SlideWidth;

% Paste the contents of the Clipboard:
pic1 = invoke(new_slide.Shapes,'Paste');

% Get height and width of picture:
pic_H = get(pic1,'Height');
pic_W = get(pic1,'Width');
maxwidth=525;
maxheight=425;
if (pic_H > maxheight || pic_W > maxwidth)
    if (pic_H/425 > pic_W/525)
        set(pic1,'Height',single(maxheight));
    else
        set(pic1,'Width',single(maxwidth));
    end
end

% Center picture on right 3/4 of page (below title area):
set(pic1,'Left',single(180));
set(pic1,'Top',single(108));





if (~isempty(text.consts))&&(~isempty(text.body))
    g1=[];
    for i=1:length(text.consts)
        if text.consts(i).val < 1e6
            g1{i}=[text.consts(i).setchan sprintf('\t%s     ','=') num2str(text.consts(i).val)];
        else
            g1{i}=[text.consts(i).setchan sprintf('\t%s     ','=') sprintf('%.2e',text.consts(i).val)];
        end
    end
    g1=sprintf('%s\n',g1{:});
    T2=cellstr(text.body);
    g2='';
    for i=1:length(T2)
    g2=[g2 T2{i} '\n'];
    end
    g=sprintf('%s\n%s',g1,g2);
elseif ~isempty(text.body)
    T2=cellstr(text.body);
    g2='';
    for i=1:length(T2)
    g2=[g2 T2{i} '\n'];
    end
    g=sprintf('%s',g2);
elseif ~isempty(text.consts)
    g1=[];
    for i=1:length(text.consts)
        if text.consts(i).val < 1e6
            g1{i}=[text.consts(i).setchan sprintf('\t%s\t','=') num2str(text.consts(i).val)];
        else
            g1{i}=[text.consts(i).setchan sprintf('\t%s\t','=') sprintf('%e4',text.consts(i).val)];
        end
    end
    g1=sprintf('%s\n',g1{:});
    g=sprintf('%s',g1);
else
    g='';
end



% Make a textbox for comments
text1 = invoke(new_slide.Shapes(1),'AddTextbox',1,single(5),single(108),single(175),single(425));
set(text1.TextFrame.TextRange.Font,'Size',single(10));
set(text1.TextFrame.TextRange,'Text',sprintf(g));

% Make a textbox for timestamp
text2 = invoke(new_slide.Shapes(1),'AddTextbox',1,single(5),single(5),single(175),single(100));
set(text2.TextFrame.TextRange.Font,'Size',single(10));
invoke(text2.TextFrame.TextRange,'InsertDateTime','ppDateTimeMMddyyHmm');


if ~exist(filespec,'file')
  % Save file as new:
  invoke(op,'SaveAs',filespec,1);
else
  % Save existing file:
  invoke(op,'Save');
end



% % Close the presentation window:
% invoke(op,'Close');
% 
% % Quit PowerPoint
% invoke(ppt,'Quit');

return