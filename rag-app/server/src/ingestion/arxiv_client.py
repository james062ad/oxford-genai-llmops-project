import requests
import xml.etree.ElementTree as ET
import json
import time
import dotenv
import os

# ✅ Load environment variables from .env
dotenv.load_dotenv()

ARXIV_API_URL = os.getenv("ARXIV_API_URL")  # e.g. http://export.arxiv.org/api/query
DATA_PATH = os.getenv("DATA_PATH")          # e.g. ./rag-app/papers-downloads


def parse_arxiv_response(response: requests.Response) -> list:
    """
    Parse the arXiv response and extract the paper titles and summaries.

    Args:
        response (requests.Response): The response object from the arXiv API.

    Returns:
        list: A list of dictionaries with paper titles and summaries.
    """
    response.raise_for_status()
    root = ET.fromstring(response.content)
    papers = []
    for entry in root.findall("{http://www.w3.org/2005/Atom}entry"):
        title = entry.find("{http://www.w3.org/2005/Atom}title").text
        summary = entry.find("{http://www.w3.org/2005/Atom}summary").text
        papers.append({"title": title.strip(), "summary": summary.strip()})
    return papers


def fetch_papers(query: str, max_results: int = 10) -> list:
    """
    Fetch papers from the arXiv API based on a query.

    Args:
        query (str): The search query.
        max_results (int): The maximum number of results to fetch.

    Returns:
        list: A list of dictionaries with paper titles and summaries.
    """
    params = {"search_query": query, "start": 0, "max_results": max_results}
    response = requests.get(ARXIV_API_URL, params=params)
    return parse_arxiv_response(response)


def fetch_papers_paginated(
    query: str,
    max_results: int = 20,
    results_per_page: int = 5,
    wait_time: int = 5,
    save_local=True,
) -> list:
    """
    Fetch papers from the arXiv API in paginated batches.

    Args:
        query (str): The search query.
        max_results (int): Total number of results to fetch.
        results_per_page (int): Number of results per page.
        wait_time (int): Seconds to wait between requests.
        save_local (bool): Whether to save each batch as a JSON file.

    Returns:
        list: Combined list of all fetched papers.
    """
    if not os.path.exists(DATA_PATH):
        os.makedirs(DATA_PATH)

    papers = []
    for i in range(0, max_results, results_per_page):
        params = {"search_query": query, "start": i, "max_results": results_per_page}
        response = requests.get(ARXIV_API_URL, params=params)
        subset = parse_arxiv_response(response)
        if save_local:
            filepath = os.path.join(DATA_PATH, f"papers_{i}_{i+results_per_page}.json")
            with open(filepath, "w") as f:
                json.dump(subset, f)
        papers += subset
        time.sleep(wait_time)
    return papers


if __name__ == "__main__":
    papers = fetch_papers_paginated(
        query="ti:perovskite",
        max_results=20,
        results_per_page=5,
        wait_time=5
    )
    print(f"Fetched {len(papers)} papers.")
