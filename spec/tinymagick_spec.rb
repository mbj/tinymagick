require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TinyMagick" do
  describe '.indentify' do
    context 'with pdf' do
      let(:result) { TinyMagick.identify('spec/data/good.pdf') }
      specify { result.should be_valid }
      specify { result.status.should == 0 }
      specify { result.error.should be_nil }

      specify do 
        result.attributes.should == {
          "size"=>314385,
          "comment"=>"",
          "directory"=>"spec/data",
          "ext"=>"pdf",
          "filename"=>"good.pdf",
          "geometry"=>"595x842+0+0",
          "height"=>842,
          "input_filename"=>"spec/data/good.pdf",
          "number_of_unique_colors"=>65190,
          "label"=>"",
          "magick_format"=>"PDF",
          "number_of_images"=>4,
          "output_filename"=>"",
          "index"=>"3",
          "quantum_depth"=>16,
          "colorspace"=>"DirectClassRGBMatte",
          "scene_number"=>3,
          "top_of_filename"=>"good",
          "temporary_filename"=>"",
          "width"=>595,
          "x_resolution"=>"72 Undefined",
          "y_resolution"=>"72 Undefined",
          "image_depth"=>16,
          "transparency_enabled"=>true,
          "compression_type"=>"Undefined",
          "dispose_method"=>"Undefined",
          "image_size"=>"595x842",
          "page_canvas_height"=>842,
          "page_canvas_offset"=>"+0+0",
          "page_canvas_size"=>"595x842",
          "compression_quality"=>"0",
          "scenes"=>"2147483647",
          "time_delay"=>"0",
          "page_canvas_width"=>595,
          "page_canvas_x_offset"=>"+0",
          "page_canvas_y_offset"=>"+0",
          "bounding_box"=>"595x810+0+0",
          "signature"=> "d14db20a3dd5ae5bb3103121500b38bda864d4bb3a07eb67f61cf44a59c21dc1",
          "error"=>nil,
          "valid"=>true,
          "status"=>0
        }
      end
    end

    context 'with bad pdf' do
      let(:result) { TinyMagick.identify('spec/data/bad.pdf') }
      specify { result.should_not be_valid }
      specify { result.status.should == 0 }
      specify do 
        result.error.should == <<-MESSAGE
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
      let(:result) { TinyMagick.identify('spec/data/missing.pdf') }
      specify { result.should_not be_valid }
      specify { result.status.should == 1 }
      specify { result.error.should =~ %r(\A#{Regexp.escape('identify: unable to open image `spec/data/missing.pdf')}) }
    end

  end
end
