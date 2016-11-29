require 'json'
require 'rest-client'

module Quip
  class QuipClient
    attr_reader :access_token, :client_id, :client_secret,
                :base_url, :request_timeout

    def initialize(options)
      @access_token = options.fetch(:access_token)
      @client_id = options.fetch(:client_id, nil)
      @client_secret = options.fetch(:client_secret, nil)
      @base_url = options.fetch(:base_url, 'https://platform.quip.com/1')
      @request_timeout = options.fetch(:request_timeout, 10)
    end

    # DOCS: https://quip.com/api/reference

    # THREADS
    def get_thread(thread_id)
      get_json("threads/#{thread_id}")
    end

    def get_threads(thread_ids)
      get_json("threads/?ids=#{thread_ids.join(',')}")
    end

    def get_recent_threads(count = 10, max_usec = nil)
      get_json("threads/recent?count=#{count}&max_updated_usec=#{max_usec}")
    end

    def create_document(content, options = {})
      post_json("threads/new-document", {
        content: content,
        format: options.fetch(:format, 'html'),
        title: options.fetch(:title, nil),
        member_ids: options.fetch(:member_ids, []).join(',')
      })
    end

    def edit_document(thread_id, content = nil, options = {})
      post_json("threads/edit-document", {
        thread_id: thread_id,
        content: content,
        location: options.fetch(:location, 0),
        section_id: options.fetch(:section_id, nil),
        format: options.fetch(:format, 'html')
      })
    end

    def add_thread_members(thread_id, member_ids)
      post_json("threads/add-members", {
        thread_id: thread_id,
        member_ids: member_ids.join(',')
      })
    end

    def remove_thread_members(thread_id, member_ids)
      post_json("threads/remove-members", {
        thread_id: thread_id,
        member_ids: member_ids.join(',')
      })
    end

    def get_blob(thread_id, blob_id)
      get_raw("blob/#{thread_id}/#{blob_id}")
    end

    def add_blob(thread_id, blob)
      post_json("blob", {
        thread_id: thread_id,
        blob: blob
      })
    end

    # MESSAGES
    def get_messages(thread_id)
      get_json("messages/#{thread_id}")
    end

    def add_message(thread_id, message)
      post_json("messages/new", {thread_id: thread_id, content: message})
    end

    # FOLDERS
    def get_folder(folder_id)
      get_json("folders/#{folder_id}")
    end

    def get_folders(folder_ids)
      get_json("folders/?ids=#{folder_ids.join(',')}")
    end

    def create_folder(title, options = {})
      post_json("folders/new", {
        title: title,
        parent_id: options.fetch(:parent_id, nil),
        color: options.fetch(:color, nil),
        member_ids: options.fetch(:member_ids, []).join(',')
      })
    end

    # TODO
    # def change_folder(folder_id)
    # end

    def add_folder_members(folder_id, member_ids)
      post_json("folders/add-members", {
        folder_id: folder_id,
        member_ids: member_ids.join(',')
      })
    end

    # USERS
    def get_user(user_id)
      get_json("users/#{user_id}")
    end

    def get_users(user_ids)
      get_json("users/?ids=#{user_ids.join(',')}")
    end

    def get_authenticated_user
      get_json('users/current')
    end

    private

    def get_raw(path)
      response = RestClient.get("#{base_url}/#{path}", {Authorization: "Bearer #{access_token}"})
      response.body
    end

    def get_json(path)
      response = RestClient.get("#{base_url}/#{path}", {Authorization: "Bearer #{access_token}"})
      JSON.parse(response.body)
    end

    def post_json(path, data)
      response = RestClient.post("#{base_url}/#{path}", data, {Authorization: "Bearer #{access_token}"})
      JSON.parse(response.body)
    end
  end
end