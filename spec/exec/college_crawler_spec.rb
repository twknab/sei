require 'spec_helper'
require 'httparty'
require 'puppeteer-ruby'
require 'factory_bot'
require_relative '../../exec/college_crawler'

describe CollegeCrawler do
  subject(:college_crawler) { described_class.new }

  # TODO: Finish this spec
  xdescribe '#run' do
    context 'when the run is successful' do
      it 'completes the run without errors' do
        allow(college_crawler).to receive(:fetch_initial_colleges).and_return([2, [college_data]])
        allow(college_crawler).to receive(:fetch_college_board_code).and_return('12345')
        allow(college_crawler).to receive(:fetch_and_process_remaining_colleges).and_return(true)
        allow(college_crawler).to receive(:create_college!).and_return(true)

        # expect(subject).to receive(:create_college!).with(
        #   'Test College', 'Test City', 'TS', '12345'
        # ).and_return(true)

        expect { subject.run }.not_to raise_error
      end
    end

    # context 'when the run fails' do
    #   it 'logs an error when fetching colleges fails' do
    #     allow(college_crawler).to receive(:fetch_college_batch).and_raise(HTTParty::Error.new('Error'))
    #     allow(logger).to receive(:error)

    #     expect { college_crawler.run }.to raise_error(HTTParty::Error)
    #     expect(logger).to have_received(:error).with(/Failed to fetch batch/)
    #   end

    #   # it 'logs an error when fetching college board code fails' do
    #   #   allow(college_crawler).to receive(:fetch_initial_colleges).and_return([2, [college_data]])
    #   #   allow(college_crawler).to receive(:fetch_college_board_code).and_raise(Puppeteer::TimeoutError.new('Timeout'))

    #   #   expect(logger).to receive(:error).with(/Failed to fetch college board code/)
    #   #   expect { college_crawler.run }.to raise_error(Puppeteer::TimeoutError)
    #   # end
    # end
  end

  # describe '#fetch_college_batch' do
  #   context 'when fetching the batch is successful' do
  #     it 'returns a valid response' do
  #       allow(HTTParty).to receive(:post).and_return(double(body: response.to_json))

  #       expect(college_crawler.send(:fetch_college_batch, 0)).to eq(response)
  #     end
  #   end

  #   context 'when fetching the batch fails' do
  #     it 'retries and logs an error after max retries' do
  #       allow(HTTParty).to receive(:post).and_raise(HTTParty::Error.new('Error'))

  #       expect(logger).to receive(:error).with(/Failed to fetch additional batch size/)
  #       expect { college_crawler.send(:fetch_college_batch, 0) }.to raise_error(HTTParty::Error)
  #     end
  #   end
  # end

  # describe '#process_colleges' do
  #   let(:progress_bar) { instance_double('ProgressBar', increment: nil) }

  #   context 'when saving the college is successful' do
  #     it 'processes colleges and increments progress bar' do
  #       allow(college_crawler).to receive(:fetch_college_board_code).and_return('12345')
  #       allow(college_crawler).to receive(:create_college!).and_return(true)

  #       expect(progress_bar).to receive(:increment).once
  #       college_crawler.send(:process_colleges, [college_data], progress_bar)
  #     end
  #   end

  #   context 'when saving the college fails' do
  #     it 'logs an error when creating a college fails' do
  #       allow(college_crawler).to receive(:fetch_college_board_code).and_return('12345')
  #       allow(college_crawler).to receive(:create_college!).and_raise(StandardError.new('Error'))

  #       expect(logger).to receive(:error).with(/Failed to create college/)
  #       expect { college_crawler.send(:process_colleges, [college_data], progress_bar) }.to raise_error(StandardError)
  #     end
  #   end
  # end

  # describe '#fetch_college_board_code' do
  #   context 'when the scrape is successful' do
  #     it 'returns a valid college board code' do
  #       allow(college_crawler).to receive(:scrape_college_board_code).and_return('12345')

  #       expect(college_crawler.send(:fetch_college_board_code, 'test-url')).to eq('12345')
  #     end
  #   end

  #   context 'when the scrape fails' do
  #     it 'retries and logs an error after max retries' do
  #       allow(college_crawler).to receive(:scrape_college_board_code).and_raise(Puppeteer::TimeoutError.new('Timeout'))

  #       expect(logger).to receive(:error).with(/Failed to fetch college board code/)
  #       expect { college_crawler.send(:fetch_college_board_code, 'test-url') }.to raise_error(Puppeteer::TimeoutError)
  #     end
  #   end
  # end
end
