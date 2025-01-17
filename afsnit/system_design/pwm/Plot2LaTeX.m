function Plot2LaTeX( h, filename, options )
%PLOT2LATEX saves matlab figure as a pdf file in vector format for
%inclusion into LaTeX. Requires free and open-source vector graphics
%editor Inkscape.
%
%   PLOT2LATEX(h,filename) saves figure with handle h to a file specified by
%   filename, without extention. Filename can contain a relative location
%   (e.g. 'images\title') to save the figure to different location.
%
%   PLOT2LATEX(h,filename, options) saves figure with specified options.
%   The y-offset of all text can be modified using options.yCorrFactor.
%   The default is options.yCorrFactor = 0.8. The units are px. With
%   options.Renderer the renderer of the figure can be specified:
%   ('opengl', 'painters').
%
%   PLOT2LATEX requires a installation of Inkscape. The program's
%   location has to be 'hard coded' into this matlab file if it differs
%   from 'c:\Program Files (x86)\Inkscape\Inkscape.exe'. Please specify
%   your inscape file location by modifying DIR_INKSC variable on the
%   first line of the actual code.
%
%   PLOT2LATEX saves the figures to .svg format. It invokes Inkscape to
%   save the svg to a .pdf and .pdf_tex file to be incorporated into LaTeX
%   document using \begin{figure} \input{image.pdf_tex} \end{figure}.
%   More information on the svg to pdf conversion can be found here:
%   ftp://ftp.fu-berlin.de/tex/CTAN/info/svg-inkscape/InkscapePDFLaTeX.pdf
%
%   PLOT2LATEX produces three files: .svg, .pdf, .pfd_tex. The .svg-file
%   contains vector image. The .pdf-file contains figure without the text.
%   The .pdf_tex-file contains the text including locations and other
%   type setting.
%
%   The produced .svg file can be manually modified in Inkscape and
%   included into the .tex file using the using the built-in "save to pdf"
%   functionality of Inkscape.
%
%   PLOT2LATEX saves the figure to a svg and pdf file with the
%   approximately the same width and height. Specify the Font size and size
%   within Matlab for correct conversion.
%
%   Workflow
%   - Matlab renames all strings of the figure to labels. The strings are
%   stored to be used later. To prevent a change in texbox size, labels are
%   padded to match the size of the texbox.
%   - Matlab saves the figure with labels to a svg file.
%   - Matlab opens the svg file and restores the labels  wiht the original
%   string
%   - Matlab invokes Inkscape to save the svg file to a pdf + pdf_tex file.
%   - The pdf_tex is to be included into LaTeX.
%
%   Features:
%   - Complex figures such as plotyy, logarithmic scales.
%   - It parses LaTeX code, even if it is not supported by Matlab LaTeX.
%   - Supports real transparency.
%   - SVG is a better supported, maintained and editable format than eps
%   - SVG allows simple manual modification into Inkscape.
%
%   Limitation:
%   - Text resize is still done in PLOT2LATEX. The LaTeX fonts in matlab do
%   not correspond completely with the LaTeX font size.
%   - Legend size is not always correct, use \hspace or \vspace in matlab
%   legend to achieve a nicer fit. Requires some iterations.
%   - Rotating 3D images using toolbar does not work, using view([]) works.
%   - Text boxes wiht LaTeX code which is not interpretable by matlab
%   results in too long text boxes.
%   - Very large figures sometimes result in very large waiting times.
%   - Older versions than matlab 2014b are not supported.
%   - PLOT2LATEX currently does not work with titles consisting of multiple
%   lines.
%   - PLOT2LATEX does not work with annotation textbox objects.
%   - PLOT2LATEX does not suport colored text.
%
%   Trouble shooting
%   - For Unix users: use the installation folder such as:
%   '/Applications/Inkscape.app/Contents/Resources/script ' as location.
%   - For Unix users: For some users the bash profiles do not allow to call
%   Inkscape in Matlab via bash. Therefore change the bash profile in Matlab
%   to something similar as setenv('DYLD_LIBRARY_PATH','/usr/local/bin/').
%   The bash profile location can be found by using '/usr/bin/env bash'

%   To do:
%   - Restore Interpreter instead of putting it to LaTeX
%   - Annotation textbox objects
%   - Allow multiple line text
%   - Use findall(h,'-property','String')
%   - Speed up code by smarter string replacent of SVG file
%   - Resize of legend box using: [h,icons,plots,str] = legend(); (not so simple)
%   - PLOT2LATEX does not suport colored text. (Matlab limitation in saving to sgv)
%   - Size difference .svg and .fig if specifying units other than px.
%       (Matlab limitation?)

%   Version:  1.2
%   Autor:    J.J. de Jong, K.G.P. Folkersma
%   Date:     20/04/2016
%   Contact:  j.j.dejong@utwente.nl

%   Change log
%   v 1.1 - 02/09/2015 (not released)
%   - Made compatible for Unix systems
%   - Added a waitbar
%   - Corrected the help file
%   v 1.2 - 20/04/2016
%   - Fixed file names with spaces in the name. (Not adviced to use in latex though)
%   - Escape special characters in XML (<,>,',",&) -> (&lt;,&gt;,&apos;,&quot;,&amp;)

%% Config and checks
%   Specify location of your inkscape installation
DIR_INKSC = '/usr/bin/inkscape';

% initize waitbar
nStep = 5; Step = 0;
hWaitBar = waitbar(Step/nStep,'Initializing');

%test if installation is correct
if ~exist(DIR_INKSC,'file')
    error([DIR_INKSC, ' cannot be found, check installation location'])
end

if verLessThan('matlab', '8.4.0.')
	error('Older versions than Matlab 2014b are not supported')
end

if ~strcmp(h.Type,'figure')
    error('h object is not a figure')
end

%% process options, first set default
yCorrFactor = 0.8; % default
% do not set default renderer

if nargin > 2
    if isfield(options,'yCorrFactor')
        yCorrFactor = options.yCorrFactor; % y offset of the text in px
    end

    if isfield(options,'Renderer') %WARNING: large size figures can become very large
        h.Renderer = options.Renderer; % set render
    else
        % Default to painters as renderer
        h.Renderer = 'painters';
    end
else
    % Default to painters as renderer
    h.Renderer = 'painters';
end

%% Find all objects with text


% Remove toolbars
AxeTBObj = findall(h,'Type','AxesToolbar');
AxeTBObj(:).delete;

TexObj = findall(h,'Type','Text'); % normal text, titels, x y z labels
LegObj = findall(h,'Type','Legend'); % legend objects
AxeObj = findall(h,'Type','Axes');  % axes containing x y z ticklabel
ColObj = findall(h,'Type','Colorbar'); % containg color bar tick


PosAnchSVG      = {'start','middle','end'};
PosAligmentSVG  = {'start','center','end'};
PosAligmentMAT  = {'left','center','right'};

n_Axe = length(LegObj);
for i = 1:n_Axe % scale text omit in next version
    LegPos(i,:) = LegObj(i).Position;
end

ChangeInterpreter(h,'Latex')
h.PaperPositionMode = 'auto'; % Keep current size

%% Replace text with a label
Step = Step + 1;
waitbar(Step/nStep,hWaitBar,'Replacing text with labels');

iLabel = 0; % generate label iterator

n_TexObj = length(TexObj);
for i = 1:n_TexObj % do for text, titles and axes labels
    iLabel = iLabel + 1;

    % find text string
    Labels(iLabel).TrueText = TexObj(i).String;

    % find text aligment
    Labels(iLabel).Alignment = PosAligmentSVG(...
                                    find(ismember(...
                                        PosAligmentMAT,...
                                        TexObj(i).HorizontalAlignment)));
	% find achor aligment svg uses this
    Labels(iLabel).Anchor = PosAnchSVG(...
                                find(ismember(...
                                    PosAligmentMAT,...
                                    TexObj(i).HorizontalAlignment)));
    % generate label
    Labels(iLabel).LabelText = LabelText(iLabel);

    %find text posiont
    Labels(iLabel).Position = TexObj(i).Position;

    % replace string with label
    TexObj(i).String = LabelText(iLabel);
end

% do similar for legend objects
n_LegObj = length(LegObj);
iLegEntry = 0;
for i = 1:n_LegObj
    n_Str = length(LegObj(i).String);

    iLegEntry = iLegEntry + 1;
    iLabel = iLabel + 1;

    Labels(iLabel).TrueText = LegObj(i).String{1};
    Labels(iLabel).Alignment = PosAligmentSVG(1); % legends are always left aligned
    Labels(iLabel).Anchor = PosAnchSVG(1);

    % generate legend label padded with dots to fill text box
    LegObj(i).String{1} = LegText(iLegEntry);
    while LegPos(i,3) >= LegObj(i).Position(3) % first label of legend should match box size
        LegObj(i).String{1} = [LegObj(i).String{1},'.'];
    end
    LegObj(i).String{1} = LegObj(i).String{1}(1:end-1);
    Labels(iLabel).LabelText = LegObj(i).String{1}; % write as label

    for j = 2:n_Str % do short as possible label for other entries
       iLegEntry = iLegEntry + 1;
       iLabel = iLabel + 1;
       Labels(iLabel).TrueText = LegObj(i).String{j};
       Labels(iLabel).Alignment = PosAligmentSVG(1);
       Labels(iLabel).Anchor = PosAnchSVG(1);
       Labels(iLabel).LabelText = LegText(iLegEntry);
       LegObj(i).String{j} = LegText(iLegEntry);
    end
end

% do similar for axes objects, XTick, YTick, ZTick
n_AxeObj = length(AxeObj);
for i = 1:n_AxeObj
    n_Str = length(AxeObj(i).XTickLabel);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        Labels(iLabel).TrueText = AxeObj(i).XTickLabel{j};
        Labels(iLabel).Alignment = PosAligmentSVG(2);
        Labels(iLabel).Anchor = PosAnchSVG(2);
        Labels(iLabel).LabelText = LabelText(iLabel);
        AxeObj(i).XTickLabel{j} = LabelText(iLabel);
    end

    isRightAx = strcmp(AxeObj(i).YAxisLocation,'right'); % exeption for yy-plot
    n_Str = length(AxeObj(i).YTickLabel);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        Labels(iLabel).TrueText = AxeObj(i).YTickLabel{j};
        if isRightAx % exeption for yy-plot, aligment is left for the right axis
            Labels(iLabel).Alignment = PosAligmentSVG(1);
            Labels(iLabel).Anchor = PosAnchSVG(1);
        else % normal y labels are right aligned
            Labels(iLabel).Alignment = PosAligmentSVG(3);
            Labels(iLabel).Anchor = PosAnchSVG(3);
        end
        Labels(iLabel).LabelText = LabelText(iLabel);
        AxeObj(i).YTickLabel{j} = LabelText(iLabel);
    end

    n_Str = length(AxeObj(i).ZTickLabel);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        Labels(iLabel).TrueText = AxeObj(i).ZTickLabel{j};
        Labels(iLabel).Alignment = PosAligmentSVG(3);
        Labels(iLabel).Anchor = PosAnchSVG(3);
        Labels(iLabel).LabelText = LabelText(iLabel);
        AxeObj(i).ZTickLabel{j} = LabelText(iLabel);
    end
end

% do similar for color bar objects
n_ColObj = length(ColObj);
for i = 1:n_ColObj
    isAxIn = strcmp(ColObj(i).AxisLocation,'in'); % find internal external text location
    isAxEast = strcmp(ColObj(i).Location,'east'); % find location
    isRightAx = isAxIn ~= isAxEast;

    n_Str = length(ColObj(i).TickLabels);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        Labels(iLabel).TrueText = ColObj(i).TickLabels{j};
        if isRightAx % if text is right aligned
            Labels(iLabel).Alignment = PosAligmentSVG(1);
            Labels(iLabel).Anchor = PosAnchSVG(1);
        else % if text is left aligned
            Labels(iLabel).Alignment = PosAligmentSVG(3);
            Labels(iLabel).Anchor = PosAnchSVG(3);
        end
        Labels(iLabel).LabelText = LabelText(iLabel);
        ColObj(i).TickLabels{j} = LabelText(iLabel);
    end
end
nLabel = iLabel;

% set text interpreter to plain text
ChangeInterpreter(h,'none');
%% Save to fig and SVG
Step = Step + 1;
waitbar(Step/nStep,hWaitBar,'Saving figure to .svg file');

% savefig(h,[filename,'_temp']); % to see the intermediate situation
print(h, '-dsvg', filename);

%saveas(h,filename,'svg'); % export to svg
%% Modify SVG file to replace labels with original text
Step = Step + 1;
waitbar(Step/nStep,hWaitBar,'Restoring text in .svg file');

for iLabel = 1:nLabel
    Labels(iLabel).XMLText = EscapeXML(Labels(iLabel).TrueText);
end


fin = fopen([filename,'.svg']); % open svg file
fout = fopen([filename,'_temp.svg'],'w'); % make a temp file for modification

StrLine_new = fgetl(fin);%skip first line
iLine = 1; % Line number
nFoundLabel = 0; % Counter of number of found labels
while ~feof(fin)
    StrPref = StrLine_new; % process new line
    iLine = iLine + 1;
    StrLine_old = fgetl(fin);

    FoundLabelText = regexp(StrLine_old,'>\S*</text','match'); %try to find label
    StrLine_new = StrLine_old;
    if ~isempty(FoundLabelText)
        nFoundLabel = nFoundLabel + 1;
        iLabel = find(ismember(...
                          	{Labels.LabelText},...
                            FoundLabelText{1}(2:end-6))); % find label number

        % Append text alignment in prevous line
        StrPrefTemp = [StrPref(1:end-1),...
                        'text-align:', Labels(iLabel).Alignment{1},...
                        ';text-anchor:', Labels(iLabel).Anchor{1}, '"'];

        % correct x - position offset
        StrPrefTemp = regexprep(StrPrefTemp,'x="\S*"','x="0"');

        % correct y - position offset, does not work correctly
        [startIndex,endIndex] = regexp(StrPrefTemp,'y="\S*"');
        yOffset = str2double(StrPrefTemp((startIndex+3):(endIndex-1)));
        StrPrefTemp = regexprep(...
                            StrPrefTemp,...
                            'y="\S*"',...
                            ['y="', num2str(yOffset*yCorrFactor), '"']);

        % Replace label with original string
        StrCurrTemp = strrep(StrLine_old, ...
                                FoundLabelText,...
                                ['>',Labels(iLabel).XMLText,'</text']);

        StrLine_new = StrCurrTemp{:};
        StrPref = StrPrefTemp;
    end
    fprintf(fout,'%s\n',StrPref);
end
fprintf(fout,'%s\n',StrLine_new);

fclose(fin);
fclose(fout);
movefile([filename,'_temp.svg'],[filename,'.svg'])
%% Invoke Inkscape to generate PDF + LaTeX
Step = Step + 1;
waitbar(Step/nStep,hWaitBar,'Saving .svg to .pdf file');

DIR_FIG = [pwd,'/'];

[status,cmdout] = system([DIR_INKSC, ...
                ' ', DIR_FIG, filename,'.svg', ...
                ' ','--export-pdf',...
                ' ', DIR_FIG, filename,'.pdf',...
                ' ','--export-latex',...
                ' ','--export-area-drawing']);

% test if a .pdf and .pdf_tex file exist
if exist([filename,'.pdf'],'file')~= 2 || exist([filename,'.pdf_tex'],'file')~= 2
    cmdout
    warning('No .pdf or .pdf_tex file produced, please check your Inkscape installation and specify installation directory correctly.')
end

%% Restore figure in matlab
% for nicety replace labels with the original text
Step = Step + 1;
waitbar(Step/nStep,hWaitBar,'Restoring Matlab figure');


iLabel = 0;
n_TexObj = length(TexObj);
for i = 1:n_TexObj %
    iLabel = iLabel + 1;
    TexObj(i).String = Labels(iLabel).TrueText;
end

n_LegObj = length(LegObj);
for i = 1:n_LegObj
    n_Str = length(LegObj(i).String);
    for j = 1:n_Str
       iLabel = iLabel + 1;
       LegObj(i).String{j} = Labels(iLabel).TrueText;
    end
end

n_AxeObj = length(AxeObj);
for i = 1:n_AxeObj
    n_Str = length(AxeObj(i).XTickLabel);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        AxeObj(i).XTickLabel{j} = Labels(iLabel).TrueText;
    end

    n_Str = length(AxeObj(i).YTickLabel);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        AxeObj(i).YTickLabel{j} = Labels(iLabel).TrueText;
    end

    n_Str = length(AxeObj(i).ZTickLabel);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        AxeObj(i).ZTickLabel{j} = Labels(iLabel).TrueText;
    end
end

n_AxeObj = length(ColObj);
for i = 1:n_AxeObj
    n_Str = length(ColObj(i).TickLabels);
    for j = 1:n_Str
        iLabel = iLabel + 1;
        ColObj(i).TickLabels{j} = Labels(iLabel).TrueText;
    end
end

% restore interpreter
ChangeInterpreter(gcf,'Latex')

close(hWaitBar);
end

function Str = LabelText(iLabel)
% LABELTEXT generates labels based on label number
    Str = 'X000';
    idStr = num2str(iLabel);
    nStr = length(idStr);
    Str(end - nStr + 1 : end ) = idStr;
end

function Str = LegText(iLedEntry)
% LEGTEXT generates legend labels based on legend entry number
    Str = num2str(iLedEntry);
end

function ChangeInterpreter(h,Interpreter)
% CHANGEINTERPRETER puts interpeters in figure h to Interpreter


    TexObj = findall(h,'Type','Text');
    LegObj = findall(h,'Type','Legend');
    AxeObj = findall(h,'Type','Axes');
    ColObj = findall(h,'Type','Colorbar');

    Obj = [TexObj;LegObj]; % Tex and Legend opbjects can be treated similar

    n_Obj = length(Obj);
    for i = 1:n_Obj
        Obj(i).Interpreter = Interpreter;
    end

    Obj = [AxeObj;ColObj]; % Axes and colorbar opbjects can be treated similar

    n_Obj = length(Obj);
    for i = 1:n_Obj
        Obj(i).TickLabelInterpreter = Interpreter;
    end
end

function strXML = EscapeXML(str)
% ESCAPEXML repaces special characters(<,>,',",&) -> (&lt;,&gt;,&apos;,&quot;,&amp;)
    escChar = {'&','<','>','''','"'};
    repChar = {'&amp;','&lt;','&gt;','&apos;','&quot;'};
    strXML = regexprep(str,escChar,repChar);
end
