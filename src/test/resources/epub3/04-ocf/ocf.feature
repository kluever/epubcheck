Feature: EPUB 3 — Open Container Format


  Checks conformance to the "Open Container Format (OCF)" section of the EPUB 3.3 specification:
    https://www.w3.org/TR/epub-33/#sec-ocf


  Background: 
    Given EPUB test files located at '/epub3/04-ocf/files/'
    And EPUBCheck with default settings


	## 4.1 OCF Abstract Container

  ###  4.1.2 File and Directory Structure

  @spec @xref:sec-container-file-and-dir-structure
  Scenario: Report publication resources found in META-INF
    When checking EPUB 'ocf-meta-inf-with-publication-resource-error'
    Then error PKG-025 is reported
    And no other errors or warnings are reported


  ###  4.1.3 File paths and file names

  @spec @xref:sec-container-filenames
  Scenario: Verify a file name containing a `+` character is allowed (issue 188)
    When checking EPUB 'ocf-container-filename-character-plus-valid'
    Then no errors or warnings are reported

  @spec @xref:sec-container-filenames
  Scenario: Report a duplicate filename if two files only differ by case
    When checking EPUB 'ocf-filename-duplicate-after-case-normalization-error.epub'
    Then error OPF-060 is reported
    And no other errors or warnings are reported

  @spec @xref:sec-container-filenames
  Scenario: Report a duplicate filename if two files have the same name after Unicode normalization
    When checking EPUB 'ocf-filename-duplicate-after-unicode-normalization-warning.epub'
    Then warning OPF-061 is reported
    And no other errors or warnings are reported

  @spec @xref:sec-container-filenames
  Scenario: Report forbidden characters in filenames
    When checking EPUB 'ocf-filename-character-forbidden-error'
    And error PKG-009 is reported
    And no other errors or warnings are reported

  Scenario: Report non-ASCII characters in filenames
    Given the reporting level is set to USAGE
    When checking EPUB 'ocf-filename-character-non-ascii-warning'
    And usage PKG-012 is reported
    And no other errors or warnings are reported
    
  ###  4.1.5 URLs in the OCF abstract container

  @spec @xref:sec-container-iri
  Scenario: Report leaking URLs in the package document
    When checking EPUB 'ocf-url-leaking-in-opf-error'
    And error RSC-026 is reported 2 times
    And no other errors or warnings are reported


  ###  4.1.6 META-INF Directory

  ####  4.1.6.3.1 Container File (container.xml)

  @spec @xref:sec-container-metainf-container.xml
  Scenario: Report an unknown element in the `container.xml` file
    When checking EPUB 'ocf-container-content-model-error'
    Then error RSC-005 is reported
    And the message contains 'element "foo" not allowed anywhere'
    And no other errors or warnings are reported

  @spec @xref:sec-container-metainf-container.xml
  Scenario: Report a missing 'container.xml' file
    When checking EPUB 'ocf-container-file-missing-fatal'
    Then fatal error RSC-002 is reported
    Then no errors or warnings are reported

  @spec @xref:sec-container-metainf-container.xml
  Scenario: Report a fatal error when checking an archive that is not an OCF
    When checking EPUB 'ocf-container-not-ocf-error.epub'
    Then fatal error RSC-002 is reported (container.xml not found)
    And error PKG-006 is reported (missing mimetype)
    Then no errors or warnings are reported

  ### 4.1.6.3.1.3 The rootfile element

  @spec @xref:sec-container.xml-rootfile-elem
  Scenario: Report a missing OPF document
    When checking EPUB 'ocf-package-document-missing-fatal'
    Then fatal error OPF-002 is reported
    And no other errors or warnings are reported


  ####  Encryption File (encryption.xml)
  
  #### 4.1.6.3.2.1 The encryption element

  @spec @xref:sec-encryption.xml-encryption
  Scenario: Report an `encryption.xml` file with invalid markup
    When checking EPUB 'ocf-encryption-content-model-error'
    Then error RSC-005 is reported
    And the message contains 'expected element "encryption"'
    And no other errors or warnings are reported

  Scenario: Verify encryption can be used
    (but file will not be parsed)
    Given the reporting level is set to INFO
    When checking EPUB 'ocf-encryption-unknown-valid'
    Then info RSC-004 is reported
    And no other errors or warnings are reported

	#FIXME !!! test that RSC-007 is reported when resource referenced in encryption.xml was not found
	   
  @spec @xref:sec-encryption.xml-encryption
  Scenario: Report an `encryption.xml` file with duplicate IDs
    When checking EPUB 'ocf-encryption-duplicate-ids-error'
    Then error RSC-005 is reported 2 times
    And the message contains 'Duplicate'
    And no other errors or warnings are reported

  #### 4.1.6.3.2.2 Order of compression and encryption
  
  @spec @xref:sec-enc-compression
  Scenario: Report an `encryption.xml` file with invalid compression metadata
    When checking EPUB 'ocf-encryption-compression-attributes-invalid-error'
    Then the following errors are reported
      | RSC-005 | value of attribute "Method" is invalid         |
      | RSC-005 | value of attribute "OriginalLength" is invalid |


  #### 4.1.6.3.6 Digital Signatures File (signatures.xml)
  
  ##### 4.1.6.3.6.1 The signatures element

  @spec @xref:sec-signatures.xml-signatures
  Scenario: Report a `signature.xml` file with invald markup
    When checking EPUB 'ocf-signatures-content-model-error'
    Then error RSC-005 is reported
    And the message contains 'expected element "signatures"'
    And no other errors or warnings are reported

  
  
  ## 4.2 OCF ZIP container  
  
  ### 4.2.2 ZIP file requirements

  @spec @xref:sec-epub-conf @xref:sec-zip-container-zipreqs
  Scenario: Verify a minimal packaged EPUB
    When checking EPUB 'ocf-zip-valid.epub'
    Then no errors or warnings are reported

  @spec @xref:sec-zip-container-zipreqs
  Scenario: Report an unreadable ZIP file (empty file)
    When checking EPUB 'ocf-zip-unreadable-empty-fatal.epub'
    Then error PKG-003 is reported
    Then fatal error PKG-008 is reported
    And the message contains 'zip file is empty'
    And no other errors or warnings are reported

  @spec @xref:sec-zip-container-zipreqs
  Scenario: Report an unreadable ZIP file (no end header)
    When checking EPUB 'ocf-zip-unreadable-no-end-header-fatal.epub'
    Then fatal error PKG-008 is reported
    And the message contains 'zip'
    And no other errors or warnings are reported

  @spec @xref:sec-zip-container-zipreqs
  Scenario: Report an unreadable ZIP file (image file with an '.epub' extension)
    When checking EPUB 'ocf-zip-unreadable-image-with-epub-extension-fatal.epub'
    Then fatal error PKG-004 is reported (corrupted ZIP header)
    Then fatal error PKG-008 is reported (error in opening ZIP file)
    And no other errors or warnings are reported

  @spec @xref:sec-zip-container-zipreqs
  Scenario: Report a duplicate ZIP entry for the same file
    When checking EPUB 'ocf-filename-duplicate-zip-entry-error.epub'
    Then error OPF-060 is reported
    And no other errors or warnings are reported


  ### 4.2.3 OCF ZIP container media type idenfication

  @spec @xref:sec-zip-container-mime
  Scenario: Report a mimetype file with an incorrect value
    When checking EPUB 'ocf-mimetype-file-incorrect-value-error'
    Then error PKG-007 is reported
    And no other errors or warnings are reported

  @spec @xref:sec-zip-container-mime
  Scenario: Report a mimetype file with leading spaces
    When checking EPUB 'ocf-mimetype-file-leading-spaces-error'
    Then error PKG-007 is reported
    And no other errors or warnings are reported

  @spec @xref:sec-zip-container-mime
  Scenario: Report a missing mimetype file
    When checking EPUB 'ocf-mimetype-file-missing-error'
    Then error PKG-006 is reported
    And no other errors or warnings are reported

  @spec @xref:sec-zip-container-mime
  Scenario: Report a mimetype file with a trailing newline
    When checking EPUB 'ocf-mimetype-file-trailing-newline-error'
    Then error PKG-007 is reported
    And no other errors or warnings are reported

  @spec @xref:sec-zip-container-mime
  Scenario: Report a mimetype file with trailing spaces
    When checking EPUB 'ocf-mimetype-file-trailing-spaces-error'
    Then error PKG-007 is reported
    And no other errors or warnings are reported

  @spec @xref:sec-zip-container-mime
  Scenario: Report when the 'mimetype' entry has an extra field in its ZIP header
    When checking EPUB 'ocf-zip-mimetype-entry-extra-field-error.epub'
    Then error PKG-005 is reported
    And no other errors or warnings are reported


  ## 4.3 Font obfuscation

  ### 4.3.5 Specifying obfuscated fonts
  
  @spec @xref:obfus-specifying
  Scenario: Verify a publication with obfuscated font
    When checking EPUB 'ocf-obfuscation-valid'
    Then no errors or warnings are reported

  @spec @xref:obfus-specifying
  Scenario: Report an obfuscated font that is not a Core Media Type
    When checking EPUB 'ocf-obfuscation-not-cmt-error'
    Then error PKG-026 is reported
    And no errors or warnings are reported

  @spec @xref:obfus-specifying
  Scenario: Report an obfuscated font that is not a font
    When checking EPUB 'ocf-obfuscation-not-font-error'
    Then error PKG-026 is reported
    And no errors or warnings are reported
