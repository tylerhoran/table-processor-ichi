module Api
  module V1
    class TablesController < ApplicationController
      def process_table
        begin
          if params[:html].nil?
            raise ArgumentError, "HTML parameter is required"
          end

          processor = TableProcessor::Processor.new(params[:html])
          result = processor.process

          render json: {
            status: "success",
            data: result
          }
        rescue ArgumentError => e
          render json: {
            status: "error",
            message: e.message
          }, status: :unprocessable_entity
        rescue StandardError => e
          Rails.logger.error("Error processing table: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
          render json: {
            status: "error",
            message: "An error occurred while processing the table"
          }, status: :internal_server_error
        end
      end
    end
  end
end
