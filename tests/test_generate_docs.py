import unittest
from pathlib import Path

from tools.generate_docs import parse_metadata, check_docs


class GenerateDocsTests(unittest.TestCase):
    def test_metadata_docs_exist(self):
        root = Path(__file__).resolve().parents[1]
        metas = parse_metadata(root / "scripts" / "ai-git-workflows.sh")
        self.assertGreaterEqual(len(metas), 9)
        errors = check_docs(metas)
        self.assertEqual(errors, [])


if __name__ == "__main__":
    unittest.main()
