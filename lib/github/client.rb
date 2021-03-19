# frozen_string_literal: true

require 'common/client/base'
require 'github/configuration'

module GitHub
  class Client < Common::Client::Base
    configuration Github::Configuration

    # def create_pr(owner, path, head, base, body, maintainer_can_modify, draft, issue)
    #   post("/repos/#{owner}/#{repo}/pulls")
    # end

    # Create a branch
    # Push code
    # Create (draft) PR

    # repo = Github::Repo.new(owner, path)

    # repo.create_blob() # https://docs.github.com/en/rest/reference/git#blobs
    # repo.create_branch()
    # repo.create_commit() # https://docs.github.com/en/rest/reference/git#create-a-commit
    # repo.create_pull_request()

    # Github::Repo::PullRequest.create()
    # Github::PullRequest.create()
  end
end
