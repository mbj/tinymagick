require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'TinyMagick' do
  let(:result) { TinyMagick.identify(path) }

  let(:attributes) { result.attributes }
  describe '.indentify' do
    shared_examples_for 'successful identification' do
      subject { result }
      specify { should be_valid }
      its(:status) { should be_zero }
      its(:error) { should be_nil }
    end

    context 'with an animated gif' do
      let(:path) { 'spec/data/animation.gif' }
      it_should_behave_like 'successful identification'

      it 'should have correct attributes' do
        attributes.should == {
         'size'=>10018,
         'comment'=>'',
         'directory'=>'spec/data',
         'ext'=>'gif',
         'filename'=>'animation.gif',
         'geometry'=>'100x100+0+0',
         'height'=>100,
         'input_filename'=>'spec/data/animation.gif',
         'number_of_unique_colors'=>182,
         'label'=>'',
         'magick_format'=>'GIF',
         'number_of_images'=>2,
         'output_filename'=>'',
         'index'=>'1',
         'quantum_depth'=>16,
         'colorspace'=>'PseudoClassRGBMatte',
         'scene_number'=>1,
         'top_of_filename'=>'animation',
         'temporary_filename'=>'',
         'width'=>100,
         'x_resolution'=>'72 Undefined',
         'y_resolution'=>'72 Undefined',
         'image_depth'=>8,
         'transparency_enabled'=>true,
         'compression_type'=>'LZW',
         'dispose_method'=>'None',
         'image_size'=>'100x100',
         'page_canvas_height'=>100,
         'page_canvas_offset'=>'+0+0',
         'page_canvas_size'=>'100x100',
         'compression_quality'=>'0',
         'scenes'=>'2147483647',
         'time_delay'=>'6',
         'page_canvas_width'=>100,
         'page_canvas_x_offset'=>'+0',
         'page_canvas_y_offset'=>'+0',
         'bounding_box'=>'100x100+0+0',
         'signature'=> 'fa432bf2da872848e64f933939c5252c78f78353201a1d1fa178be2907b39ecf',
         'error'=>nil,
         'valid'=>true,
         'status'=>0
        }
      end
    end

    context 'with gif in a file extended as .jpg' do
      let(:path) { 'spec/data/actually_a_gif.jpg' }
      it_should_behave_like 'successful identification'
      specify 'magick_format should be reported correctly' do
        result.magick_format.should == 'GIF'
      end
    end

    context 'with gif' do
      let(:path) { 'spec/data/simple.gif' }
      it_should_behave_like 'successful identification'

      it 'should have correct attributes' do
        attributes.should == {
          'size'=>4707,
          'comment'=>'',
          'directory'=>'spec/data',
          'ext'=>'gif',
          'filename'=>'simple.gif',
          'geometry'=>'150x55+0+0',
          'height'=>55,
          'input_filename'=>'spec/data/simple.gif',
          'number_of_unique_colors'=>256,
          'label'=>'',
          'magick_format'=>'GIF',
          'number_of_images'=>1,
          'output_filename'=>'',
          'index'=>'0',
          'quantum_depth'=>16,
          'colorspace'=>'PseudoClassRGB',
          'scene_number'=>0,
          'top_of_filename'=>'simple',
          'temporary_filename'=>'',
          'width'=>150,
          'x_resolution'=>'72 Undefined',
          'y_resolution'=>'72 Undefined',
          'image_depth'=>8,
          'transparency_enabled'=>false,
          'compression_type'=>'LZW',
          'dispose_method'=>nil,
          'image_size'=>'150x55',
          'page_canvas_height'=>55,
          'page_canvas_offset'=>'+0+0',
          'page_canvas_size'=>'150x55',
          'compression_quality'=>'0',
          'scenes'=>'2147483647',
          'time_delay'=>'0',
          'page_canvas_width'=>150,
          'page_canvas_x_offset'=>'+0',
          'page_canvas_y_offset'=>'+0',
          'bounding_box'=>'149x52+1+3',
          'signature'=> '2bb118e1bc81ed576dd1313dcf1a167310be4d8579e5220d67f8f023557e3788',
          'error'=>nil,
          'valid'=>true,
          'status'=>0
        }
      end
    end

    context 'with pdf' do
      let(:path) { 'spec/data/good.pdf' }
      it_should_behave_like 'successful identification'

      it 'should have correct attributes' do 
        attributes.should == {
          'size'=>314385,
          'comment'=>'',
          'directory'=>'spec/data',
          'ext'=>'pdf',
          'filename'=>'good.pdf',
          'geometry'=>'595x842+0+0',
          'height'=>842,
          'input_filename'=>'spec/data/good.pdf',
          'number_of_unique_colors'=>65190,
          'label'=>'',
          'magick_format'=>'PDF',
          'number_of_images'=>4,
          'output_filename'=>'',
          'index'=>'3',
          'quantum_depth'=>16,
          'colorspace'=>'DirectClassRGBMatte',
          'scene_number'=>3,
          'top_of_filename'=>'good',
          'temporary_filename'=>'',
          'width'=>595,
          'x_resolution'=>'72 Undefined',
          'y_resolution'=>'72 Undefined',
          'image_depth'=>16,
          'transparency_enabled'=>true,
          'compression_type'=>nil,
          'dispose_method'=>nil,
          'image_size'=>'595x842',
          'page_canvas_height'=>842,
          'page_canvas_offset'=>'+0+0',
          'page_canvas_size'=>'595x842',
          'compression_quality'=>'0',
          'scenes'=>'2147483647',
          'time_delay'=>'0',
          'page_canvas_width'=>595,
          'page_canvas_x_offset'=>'+0',
          'page_canvas_y_offset'=>'+0',
          'bounding_box'=>'595x810+0+0',
          'signature'=> 'd14db20a3dd5ae5bb3103121500b38bda864d4bb3a07eb67f61cf44a59c21dc1',
          'error'=>nil,
          'valid'=>true,
          'status'=>0
        }
      end
    end

    context 'with bad pdf' do
      let(:path) { 'spec/data/bad.pdf' }
      subject { result }
      specify { should_not be_valid }
      its(:status) { should == 0 }
      its(:error) do should == <<-MESSAGE
   **** Warning: Short look-up table in the Indexed color space was padded with 0's.

   **** This file had errors that were repaired or ignored.
   **** The file was produced by: 
   **** >>>> Acrobat Distiller 9.0.0 (Windows) <<<<
   **** Please notify the author of the software that produced this
   **** file that it does not conform to Adobe's published PDF
   **** specification.

        MESSAGE
      end
    end

    context 'with missing file' do
      let(:path) { 'spec/data/missing.pdf' }
      subject { result }
      specify { should_not be_valid }
      its(:status) { should == 1 }
      its(:error) { should =~ %r(\A#{Regexp.escape('identify: unable to open image `spec/data/missing.pdf')}) }
    end
  end
end
