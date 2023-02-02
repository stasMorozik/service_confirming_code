test:
	docker run --rm --name test_service_confirming_code -v /projects/service_confirming_code:/service_confirming_code test_service_confirming_code
run:
	docker run --rm --name service_confirming_code -v /projects/service_confirming_code:/service_confirming_code service_confirming_code
