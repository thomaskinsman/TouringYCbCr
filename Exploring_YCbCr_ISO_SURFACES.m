
function Exploring_YCbCr_ISO_SURFACES_v610()
% Generate 256 planes of (YCbCr) which have uniform luminance levels.
% Each plane has all possible Cb values, going from the left to the right  across the image.
% Each plane has all possible Cr values, going from the top  to the bottom across the image.
%
% Each successive plane has increasing luminance.
%
% About 24 points are sampled from one of the mid-luminance levels,
% and printed out in a table for inclusion in the paper.
%
% Thomas B. Kinsman
% Sept  2018
%
LABEL_THE_PROBE_POINTS_ON_FRAME_128 = false;            % Set to true to put the spots on frame 128.
                                                        % These are the points in YCbCr space that 
                                                        % all have the same Y value.
                                                        %
                                                        % By default we turn this off to make
                                                        % the video of the "tour" not have the
                                                        % points marked in it.
                                                        %
                                                        % Turn it on to generate the figure for the 
                                                        % publication.
                                                        %

%
%  The following two directory names use the OsX forward slash.
%  For complete compatibility, you would use the file separator
%  for the current OS.
%
%  filesep() Generates that:
%
OUTPUT_DIR_FOR_FRAMES = './INDIVIDUAL_FRAMES/';         % Directory to save individual frames.
OUTPUT_DIR_FOR_FIGSS  = './INDIVIDUAL_EPS_FIGS/';       % Directory for figures for LaTeX article.

% Here are the OS Independent versions:
OUTPUT_DIR_FOR_FRAMES = [ '.' filesep() 'INDIVIDUAL_FRAMES'   filesep() ]; 
OUTPUT_DIR_FOR_FIGSS  = [ '.' filesep() 'INDIVIDUAL_EPS_FIGS' filesep() ];

FS_IN_FIG             = 24;                             % Font size for the figure.

% Here we generate some points on the (Cr,Cb) plane.
% These are the points we sample to generate the table 
% of iso-luminance points.
% 
% We use the values of theta (angles in degrees) and
% a set radius, to find some (X,Y) points to sample.
%
thetas  = 0:15:359;             % Angles, in degrees.
Radius  = 62.25;
xs      = round( cosd( thetas ) * Radius + 128 );
ys      = round( sind( thetas ) * Radius + 128 );


%
%  CREATE THE DIRECTORIES, IF NEEDED:
%
    if ( exist( OUTPUT_DIR_FOR_FRAMES ) == 0 )
        mkdir( OUTPUT_DIR_FOR_FRAMES );
    else
        fprintf('Directory %s already exists.\n', OUTPUT_DIR_FOR_FRAMES);
    end
    
    if ( exist( OUTPUT_DIR_FOR_FIGSS ) == 0 )
        mkdir( OUTPUT_DIR_FOR_FIGSS );
    else
        fprintf('Directory %s already exists.\n', OUTPUT_DIR_FOR_FIGSS);
    end


    probe_pts_xy = [   xs.', ys.' ];

    % Create all levels from 0 to 1 for a double image:
    All_levels          = 0.0:1/255:1.0;
    
    %
    % The magic of meshgrid fills in the Cb and Cr values automatically.
    % However, the values that come out of MeshGrid increase towards the 
    % bottom of the image.  We reverse this later on to match the 
    % human intuition that "things increase as we go up."
    %
    [Cb_s, Cr_s]        = meshgrid( All_levels );
   
    % Here we build up the image, layer by layer.
    YCbCr_Img           = zeros( 256, 256, 3 );         % Allocate memory space.
    YCbCr_Img(:,:,1)    = 0.5*ones(256,256);            % First  layer --> luminance.
    YCbCr_Img(:,:,2)    = Cb_s;                         % Second layer --> Cb
    
    %
    % Here is the reversing of one channel:
    %
    % Make the amount of Cr increase UP towards the top of the image 
    % instead of down.  
    %
    % The values that come out of meshgrid go down towards the bottom.
    YCbCr_Img(:,:,3)    = 1 - Cr_s;                      % Third layer --> Cr
    
    % Use the current matlab filename, from mfilename(),
    % and pull it apart into parts:
    % A.  The directory of the file.
    % B.  The basename  of the file.
    % C.  The extension of the file.    
    [dr,bn,ex] = fileparts( mfilename() );

    figure('Position', [10, 50, 570, 570] ); 
    
    % Create the video file, then set a few parameters,
    % and finally open the output file:
    fn_out_avi      = sprintf('%s.avi', bn );
    vw              = VideoWriter( fn_out_avi );
    vw.FrameRate  = 30;
    vw.open();

    %
    frame_counter = 0;      % Goes up with the luminance level.
    for Y = All_levels( [ 1:end end:-1:1 ] )

        YCbCr_Img(:,:,1)    = Y;

        img_rgb             = ycbcr2rgb( YCbCr_Img );

        imagesc( img_rgb );
        axis image;
        set(gca,'Position', [0.075 0.075 0.90 0.85]);

        axis off;
        set(gcf,'Color','w');
      
        %  Create the Luminance amount of this "slice" through YCbCr colorspace.
        %  And add axes that show the direction of Cb and Cr.
        
        ttl = sprintf('Y \\approx %6.3f\n', Y );
        text( 128, -3, ttl,  ...
                        'FontSize', FS_IN_FIG, ...
                        'HorizontalAlignment', 'center' );
                        
        text( 128, 270, 'Increasing C_B (CHANGE IN BLUE) \rightarrow', ...
                        'FontSize', FS_IN_FIG, ...
                        'HorizontalAlignment', 'center' );
        text(  -10, 128, 'Increasing C_R (CHANGE IN RED) \rightarrow', ...
                        'FontSize', FS_IN_FIG, ...
                        'HorizontalAlignment', 'center', ...
                        'Rotation', 90 );
        drawnow;
        
        % 
        %  LABEL THE PROBE POINTS:
        %
        hold on;
        
        
        %
        %  Do this only for one layer:
        %
        if ( frame_counter == 128 )
            for pt_idx = 1 : size( probe_pts_xy, 1 )
                x = probe_pts_xy(pt_idx,1);
                y = probe_pts_xy(pt_idx,2);
                hold on;
                if ( LABEL_THE_PROBE_POINTS_ON_FRAME_128 )
                    tmp_str = sprintf('%2d', pt_idx);
                    text( x-5, y, tmp_str, 'FontSize', 16 );
                    plot( x, y, 'ko', 'MarkerSize', 30, 'LineWidth', 1.5 );
                end
            end

            % Sample that luminance plane, all of uniform Y value.
            for idx = 1:size(probe_pts_xy,1)
                x                               = probe_pts_xy(idx,1);
                y                               = probe_pts_xy(idx,2);
                YCbCr_IsoSurface( idx, 1:3 )    = ...
                    [ YCbCr_Img(y,x,1),  YCbCr_Img(y,x,2),  YCbCr_Img(y,x,3) ] ; 
            end

            % Convert those values back to a form we can publish in a table later on.
            rgbs_isosurface = ycbcr2rgb( YCbCr_IsoSurface ); 
        end
        
        drawnow;
        
        
        % Save the current frame to the video,
        % then save it to a JPEG image for display in presentations,
        % then save it to a Encapsulated Postscript image for inclusion in the paper.
        fr = getframe( gcf() );
        vw.writeVideo( fr );
        
        % Create a JPEG image for publication:
        fn_out_jpeg = sprintf( '%sFig_%03d_Y%04d.jpg', OUTPUT_DIR_FOR_FRAMES, frame_counter, round(Y*1000) );
        imwrite( fr.cdata, fn_out_jpeg, 'JPEG', 'QUALITY', 100 );
        
        % Create an Encapsulated PostScript file, with a TIFF Preview Image:
        fn_out_eps  = sprintf( '%sFig_%03d_Y%04d.eps', OUTPUT_DIR_FOR_FIGSS, frame_counter, round(Y*1000) );
        print(fn_out_eps, '-depsc', '-tiff');
        
        hold off;
        frame_counter = frame_counter + 1;
    end
    
    % Close the output video writer, so that file is terminated nicely:
    vw.close();
    
    
    fprintf('All of these YCbCr  luminances should be the same:\n');
    % Intentionally do not use a semi-colon, so that values are printed out:
    YCbCr_check     = rgb2ycbcr( rgbs_isosurface )      % Works if all the same values.
    
    % Print the table for LaTeX, for the article.
    fprintf( '\\hline\n' );
    fprintf( 'Row ID&Red&Green&Blue&$Y$ of $YC_BC_R$\\\\\n');
    for idx = 1:size(rgbs_isosurface,1)
        fprintf( '\\hline\n' );
        fprintf( '%d&%6.4f&%6.4f&%6.4f&%6.3f\\\\\n', idx, rgbs_isosurface(idx,:), YCbCr_check(idx,1) );
    end
    fprintf( '\\hline\n' );
    
    fprintf('\n');
    
    % Print the table for Matlab use later on:
    fprintf( '%% Example & Red & Green & Blue \n');
    fprintf( 'rgb_values = [ ...\n');
    for idx = 1:size(rgbs_isosurface,1)
        fprintf( '\t\t%6.4f , %6.4f , %6.4f ;\n', rgbs_isosurface(idx,:) );
    end
    fprintf('\t\t];\n');
    
end

