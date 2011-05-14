require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TinyMagick" do
  describe '.indentify' do
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
